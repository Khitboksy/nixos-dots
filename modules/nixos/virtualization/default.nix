{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.virt.vms;

  # Libvirt QEMU hook script
  hookScript = pkgs.writeShellScript "libvirt-qemu-hook" ''
    #!/run/current-system/sw/bin/bash
    # libvirt qemu hook
    # Arguments: $1 = domain name, $2 = operation (prepare|start|started|stopped|release)
    set -e

    DOMAIN="$1"
    OPERATION="$2"

    case "$DOMAIN" in
      ${concatStringsSep "\n  " (
        map (d: ''
          "${d.name}")
            case "$OPERATION" in
              prepare)
                echo "[vm-hook] Preparing ${d.name}: stopping DM, unbinding GPU"
                systemctl stop greetd 2>/dev/null || true
                sleep 1

                ${optionalString d.nvidiaHack ''
                  modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia i2c_nvidia_gpu 2>/dev/null || true
                  sleep 1
                ''}

                for dev in ${concatStringsSep " " d.pci} ${concatStringsSep " " d.audio} \
                           ${concatStringsSep " " d.usb} ${concatStringsSep " " d.ucsi}; do
                  if [ -e "/sys/bus/pci/devices/$dev/driver" ]; then
                    echo "$dev" > "/sys/bus/pci/devices/$dev/driver/unbind" 2>/dev/null || true
                  fi
                done

                for dev in ${concatStringsSep " " d.pci} ${concatStringsSep " " d.audio} \
                           ${concatStringsSep " " d.usb} ${concatStringsSep " " d.ucsi}; do
                  echo "vfio-pci" > "/sys/bus/pci/devices/$dev/driver_override" 2>/dev/null || true
                  echo "$dev" > "/sys/bus/pci/drivers/vfio-pci/bind" 2>/dev/null || true
                done

                chvt 2 2>/dev/null || true
                echo "[vm-hook] ${d.name} ready for passthrough"
                ;;

              release)
                echo "[vm-hook] Releasing ${d.name}: rebinding GPU, restarting DM"
                for dev in ${concatStringsSep " " d.pci} ${concatStringsSep " " d.audio} \
                           ${concatStringsSep " " d.usb} ${concatStringsSep " " d.ucsi}; do
                  echo "$dev" > "/sys/bus/pci/drivers/vfio-pci/unbind" 2>/dev/null || true
                  echo "" > "/sys/bus/pci/devices/$dev/driver_override" 2>/dev/null || true
                done

                echo 1 > /sys/bus/pci/rescan 2>/dev/null || true
                sleep 2

                ${optionalString d.nvidiaHack ''
                  modprobe nvidia_drm nvidia_modeset nvidia_uvm nvidia 2>/dev/null || true
                  sleep 1
                ''}

                systemctl start greetd 2>/dev/null || true
                echo "[vm-hook] ${d.name} released, DM restarted"
                ;;
            esac
            ;;
        '') config.virt.vms._gpuDomains
      )}
      *)
        exit 0
        ;;
    esac
  '';

in

{
  # Import individual VM definitions from vms/*.nix
  # Each file declares options.virt.vms.<name> independently
  imports = [
    ./vms/tiny10.nix
  ];

  options.virt.vms = with types; {
    enable = mkBoolOpt false ''
      Enable hypervisor infrastructure + declarative VM management.
      Enables libvirtd, IOMMU/VFIO, virt-manager, and GPU passthrough hooks.
      Add individual VM definitions under `virt.vms.<name>.enable = true`
      (each VM is its own module in virtualization/vms/*.nix).
    '';

    _gpuDomains = mkOption {
      type = listOf (submodule {
        options = {
          name = mkOpt str "vm" "Libvirt domain name.";
          pci = mkOpt (listOf str) [ ] "GPU PCI addresses.";
          audio = mkOpt (listOf str) [ ] "GPU audio PCI addresses.";
          usb = mkOpt (listOf str) [ ] "GPU USB PCI addresses.";
          ucsi = mkOpt (listOf str) [ ] "GPU UCSI PCI addresses.";
          nvidiaHack = mkBoolOpt true "Unload/reload NVIDIA modules around VM lifecycle.";
        };
      });
      default = [ ];
      internal = true;
      description = ''
        Internal aggregation of GPU-passthrough VM configs.
        VM modules contribute their GPU devices here; the hook script
        is generated from this list.
      '';
    };
  };

  config = mkIf cfg.enable {

    # IOMMU + VFIO kernel config
    boot = {
      kernelParams = [
        (if pkgs.stdenv.hostPlatform.isx86_64 then "amd_iommu=on" else "intel_iommu=on")
        "iommu=pt"
        "kvm.ignore_msrs=1"
      ];
      kernelModules = [
        # KVM virtualization (modprobe skips non-existent modules silently)
        "kvm"
        "kvm_amd"
        "kvm_intel"
        # VFIO for PCI passthrough (late-bind via hooks)
        "vfio"
        "vfio_iommu_type1"
        "vfio_pci"
        "vfio_virqfd"
      ];
    };

    # Libvirtd
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
      onBoot = "ignore";
      onShutdown = "shutdown";
      allowedBridges = [ "virbr0" ];
    };

    programs.virt-manager.enable = true;

    # User groups & packages
    users.groups.libvirtd.members = [ "helios" ];

    environment.systemPackages = with pkgs; [
      virt-manager
      virt-viewer
      spice-gtk
      looking-glass-client
      OVMF
      swtpm
      qemu_kvm
    ];

    # Libvirt QEMU hook
    virtualisation.libvirtd.hooks.qemu = {
      qemu = hookScript;
    };

    # Performance tuning
    #boot.kernel.sysctl = {
    #  "vm.nr_hugepages" = 2048;
    #};
  };
}
