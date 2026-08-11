{
  lib,
  zenith,
  pkgs,
  config,
  ...
}:

with zenith.lib';

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
  options.virt.vms.${vmName} = with lib.types; {

    enable = mkBoolOpt false "Enable the ${vmName} virtual machine (Clip Studio Paint on Windows).";

    iso = mkOpt (nullOr str) null ''
      Path to the Windows installation ISO on disk (e.g. "/var/lib/libvirt/images/tiny10.iso").
      Set to null after install to boot from disk.
    '';

    virtioIso = mkOpt (nullOr str) null ''
      Path to virtio-win.iso on disk — provides VirtIO disk/network drivers
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

  config = lib.mkIf (config.virt.vms.enable && cfg.enable) {

    # ------------------------------------------------------------------
    # Cockpit web UI — access via Tailscale Serve on terra
    # ------------------------------------------------------------------
    services.cockpit = {
      enable = true;
      port = lib.mkDefault 9090;
      openFirewall = false; # Exposed via Tailscale Serve
      plugins = with pkgs; [
        cockpit-machines
      ];
      allowed-origins = [
        "https://terra.tail9a2d08.ts.net"
        "https://localhost"
        "http://localhost"
      ];
      settings = {
        WebService = {
          AllowUnencrypted = true;
          ProtocolHeader = "X-Forwarded-Proto";
        };
      };
    };

    # ------------------------------------------------------------------
    # Libvirt-D-Bus bridge — cockpit-machines talks to libvirtd via D-Bus
    # ------------------------------------------------------------------
    services.dbus.packages = [ pkgs.libvirt-dbus ];

    users.users.libvirtdbus = {
      isSystemUser = true;
      group = "libvirtdbus";
      extraGroups = [ "libvirtd" ];
    };
    users.groups.libvirtdbus = { };

    systemd.services.libvirt-dbus = {
      description = "Libvirt D-Bus bridge";
      after = [ "libvirtd.service" ];
      requires = [ "libvirtd.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "dbus";
        BusName = "org.libvirt";
        User = "libvirtdbus";
        Group = "libvirtdbus";
        ExecStart = "${pkgs.libvirt-dbus}/bin/libvirt-dbus --system";
      };
    };

    # ------------------------------------------------------------------
    # Activation — creates disk image on every rebuild/boot
    # ------------------------------------------------------------------
    system.activationScripts."disk-${vmName}" = lib.stringAfter [ "var" ] ''
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
