{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
with lib.custom;

let
  vmName = "csp-win";
  cfg = config.virt.vms.${vmName};
  shared = import ../shared.nix { inherit pkgs lib; };

  # Deterministic UUID from vmName
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

    enable = mkBoolOpt false "Enable the ${vmName} virtual machine (Clip Studio Paint on Windows).";

    iso = mkOpt (nullOr path) null ''
      Path to the Windows installation ISO.
      Set to null after install to boot from disk.
    '';

    virtioIso = mkOpt (nullOr path) null ''
      Path to virtio-win.iso — provides VirtIO disk/network drivers
      for Windows during installation.
    '';

    memory = mkIntOpt 12288 "RAM in MiB (default 12288 = 12 GB)";

    vcpu = mkIntOpt 4 "Virtual CPU count";

    diskSize = mkStringOpt "50G" "Size of the QCOW2 disk image";

    graphics = mkOpt (nullOr str) "spice" ''
      QEMU display type: "spice", "vnc", or null.
      Defaults to "spice" for remote desktop access via Cockpit.
    '';

  };

  config = mkIf (config.virt.vms.enable && cfg.enable) {

    # ------------------------------------------------------------------
    # Activation — creates disk image on every rebuild/boot
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
          os = "windows";
          firmware = "uefi";
          tpm = true;
          gpu = {
            pci = [ ];
            audio = [ ];
            usb = [ ];
            ucsi = [ ];
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

    # ------------------------------------------------------------------
    # Systemd service — on-demand VM lifecycle
    # `systemctl start csp-win` starts the VM
    # `systemctl stop csp-win` gracefully shuts it down
    # ------------------------------------------------------------------
    systemd.services.${vmName} = {
      description = "Clip Studio Paint Windows VM";
      after = [
        "libvirtd.service"
        "define-${vmName}.service"
      ];
      requires = [ "libvirtd.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${pkgs.libvirt}/bin/virsh start ${vmName}
      '';
      preStop = ''
        ${pkgs.libvirt}/bin/virsh shutdown ${vmName} --mode acpi
      '';
    };
  };
}
