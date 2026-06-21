{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
with lib.custom;

let
  vmName = "tiny10"; # ← CHANGE THIS when copying
  cfg = config.virt.vms.${vmName};
  shared = import ../shared.nix { inherit pkgs lib; };

  genUUID =
    name:
    let
      h = s: builtins.hashString "sha256" s;
    in
    builtins.substring 0 8 (h name)
    + "-"
    + builtins.substring 8 4 (h "${name}-p2")
    + "-"
    + builtins.substring 12 4 (h "${name}-p3")
    + "-"
    + builtins.substring 16 4 (h "${name}-p4")
    + "-"
    + builtins.substring 20 12 (h "${name}-p5");

in

{
  options.virt.vms.${vmName} = with types; {

    enable = mkBoolOpt false ''
      Enable the ${vmName} virtual machine.
    '';

    iso = mkOpt (nullOr path) null ''
      Path to the ${vmName} installation ISO.
      Set to null after install to boot from disk.
    '';

    virtioIso = mkOpt (nullOr path) null ''
      Path to virtio-win.iso — provides VirtIO disk/network drivers
      for Windows during installation.
    '';

    memory = mkOpt int 16384 ''
      RAM in MiB (default 16384 = 16 GB).
    '';

    vcpu = mkOpt int 8 ''
      Virtual CPU count.
    '';

    gpuPassthrough = mkBoolOpt true ''
      Enable GPU passthrough. Hooks unbind/rebind the GPU
      from NVIDIA driver around VM lifecycle.
    '';

    gpu = {
      pci = mkOpt (listOf str) [ ] "GPU PCI addresses (e.g. 0000:2b:00.0).";
      audio = mkOpt (listOf str) [ ] "GPU HDMI audio PCI (e.g. 0000:2b:00.1).";
      usb = mkOpt (listOf str) [ ] "GPU USB controller PCI (e.g. 0000:2b:00.2).";
      ucsi = mkOpt (listOf str) [ ] "GPU USB-C UCSI PCI (e.g. 0000:2b:00.3).";
    };

    nvidiaHack = mkBoolOpt true ''
      Unload NVIDIA kernel modules before GPU passthrough and
      reload them after. Must be true for NVIDIA GPUs.
      The RTX 2080 uses NVIDIA, so this defaults to true.
    '';

    diskSize = mkStringOpt "120G" ''
      Size of the QCOW2 disk image.
    '';

  };

  config = mkIf (config.virt.vms.enable && cfg.enable) {

    virt.vms._gpuDomains = optional cfg.gpuPassthrough {
      name = vmName;
      pci = cfg.gpu.pci;
      audio = cfg.gpu.audio;
      usb = cfg.gpu.usb;
      ucsi = cfg.gpu.ucsi;
      inherit (cfg) nvidiaHack;
    };

    # ──────────────────────────────────────────────────────────
    #  Activation — creates disk image on every rebuild/boot
    #  (runs early, doesn't need libvirtd)
    # ──────────────────────────────────────────────────────────
    system.activationScripts."disk-${vmName}" = stringAfter [ "var" ] ''
      mkdir -p /var/lib/libvirt/images

      if [ ! -f "/var/lib/libvirt/images/${vmName}.qcow2" ]; then
        ${pkgs.qemu_kvm}/bin/qemu-img create -f qcow2 \
          "/var/lib/libvirt/images/${vmName}.qcow2" ${cfg.diskSize}
      fi
    '';

    # ──────────────────────────────────────────────────────────
    #  Systemd oneshot — defines the domain AFTER libvirtd is
    #  fully ready. Runs on every boot.
    # ──────────────────────────────────────────────────────────
    systemd.services."define-${vmName}" = {
      description = "Define ${vmName} libvirt domain";
      after = [ "libvirtd.service" ];
      requires = [ "libvirtd.service" ];
      wantedBy = [ "libvirtd.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
                DOMAIN_XML=$(mktemp)
                trap "rm -f '$DOMAIN_XML'" EXIT
                cat > "$DOMAIN_XML" << 'XML'
        ${shared.genDomainXML vmName {
          uuid = genUUID vmName;
          iso = cfg.iso;
          virtioIso = cfg.virtioIso;
          memory = cfg.memory;
          vcpu = cfg.vcpu;
          os = "windows";
          firmware = "uefi";
          tpm = false;
          gpu = {
            pci = cfg.gpu.pci;
            audio = cfg.gpu.audio;
            usb = cfg.gpu.usb;
            ucsi = cfg.gpu.ucsi;
          };
          disks.main.path = "/var/lib/libvirt/images/${vmName}.qcow2";
          network = {
            type = "network";
            name = "default";
            bridge = "virbr0";
          };
          onPoweroff = "destroy";
          onReboot = "restart";
          onCrash = "destroy";
          graphics = null;
        }}
        XML
                ${pkgs.libvirt}/bin/virsh define "$DOMAIN_XML"
      '';
    };
  };
}
