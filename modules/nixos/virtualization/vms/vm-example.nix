{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
with lib.custom;

let
  vmName = "vm-example"; # ← CHANGE THIS when copying (must match filename)
  cfg = config.virt.vms.${vmName};
  shared = import ../shared.nix { inherit pkgs lib; };

  # Deterministic UUID from vmName — valid UUIDv4 format, unique per name
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
      Path to the OS installation ISO (e.g. /iso/fedora.iso).
      Set to null after install to boot from disk.
    '';

    virtioIso = mkOpt (nullOr path) null ''
      Path to virtio-win.iso — only needed for Windows guests
      during installation (provides VirtIO disk/network drivers).
    '';

    memory = mkOpt int 4096 ''
      RAM in MiB (default 4096 = 4 GB).
    '';

    vcpu = mkOpt int 4 ''
      Virtual CPU count.
    '';

    os = mkOption {
      type = types.enum [
        "linux"
        "windows"
      ];
      default = "linux";
      description = ''
        Guest OS family. "windows" enables Hyper-V enlightenments,
        KVM hiding (needed for EAC), localtime clock, and SMM.
        "linux" uses a simpler kvmclock configuration.
      '';
    };

    firmware = mkOption {
      type = types.enum [
        "uefi"
        "bios"
      ];
      default = "uefi";
      description = ''
        Firmware type. UEFI (OVMF) is required for Windows 11
        and recommended for most modern OSes.
      '';
    };

    tpm = mkBoolOpt false ''
      Enable emulated TPM 2.0 device (required for Windows 11).
    '';

    diskSize = mkStringOpt "40G" ''
      Size of the QCOW2 disk image, e.g. "40G" or "120G".
      Created automatically on first activation.
    '';

    gpuPassthrough = mkBoolOpt false ''
      Pass the host GPU through to this VM.
      When enabled, the host loses GPU access while the VM runs.
      Configure the PCI addresses in gpu.* options below.
    '';

    graphics = mkOpt (nullOr str) null ''
      QEMU display type: "spice", "vnc", or null for no QEMU display
      (e.g. GPU passthrough uses the monitor directly).
    '';

    nvidiaHack = mkBoolOpt false ''
      Unload NVIDIA kernel modules before GPU passthrough and
      reload them after. Must be true for NVIDIA GPUs.
      Set false for AMD GPUs.
    '';

    gpu = {
      pci = mkOpt (listOf str) [ ] "GPU PCI addresses (e.g. 0000:2b:00.0).";
      audio = mkOpt (listOf str) [ ] "GPU audio PCI (e.g. 0000:2b:00.1).";
      usb = mkOpt (listOf str) [ ] "GPU USB PCI (e.g. 0000:2b:00.2).";
      ucsi = mkOpt (listOf str) [ ] "GPU UCSI PCI (e.g. 0000:2b:00.3).";
    };

  };

  config = mkIf (config.virt.vms.enable && cfg.enable) {

    # ------------------------------------------------------------------
    # Register GPU devices for the single-GPU passthrough hook
    # ------------------------------------------------------------------
    virt.vms._gpuDomains = optional cfg.gpuPassthrough {
      name = vmName;
      pci = cfg.gpu.pci;
      audio = cfg.gpu.audio;
      usb = cfg.gpu.usb;
      ucsi = cfg.gpu.ucsi;
      inherit (cfg) nvidiaHack;
    };

    # ------------------------------------------------------------------
    # Activation — creates disk image on every rebuild/boot
    # (runs early, doesn't need libvirtd)
    # ------------------------------------------------------------------
    system.activationScripts."disk-${vmName}" = stringAfter [ "var" ] ''
      mkdir -p /var/lib/libvirt/images

      if [ ! -f "/var/lib/libvirt/images/${vmName}.qcow2" ]; then
        ${pkgs.qemu_kvm}/bin/qemu-img create -f qcow2 \
          "/var/lib/libvirt/images/${vmName}.qcow2" ${cfg.diskSize}
      fi
    '';

    # ------------------------------------------------------------------
    # Systemd oneshot — defines the domain AFTER libvirtd is fully
    # ready. Runs on every boot.
    # ------------------------------------------------------------------
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
          os = cfg.os;
          firmware = cfg.firmware;
          tpm = cfg.tpm;
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
          graphics = cfg.graphics;
        }}
        XML
                ${pkgs.libvirt}/bin/virsh define "$DOMAIN_XML"
      '';
    };
  };
}
