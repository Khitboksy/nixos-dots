{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.custom; let
  cfg = config.wms.hyprland;

  mkService = recursiveUpdate {
    Unit.PartOf = ["graphical-session.target"];
    Unit.After = ["graphical-session.target"];
    Install.WantedBy = ["graphical-session.target"];
  };

  mod = "SUPER";
in {
  options.wms.hyprland = with types; {
    enable = mkBoolOpt false "Enable Hyprland";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      xwayland
      grim
      slurp
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      xwayland.enable = true;

      systemd = {
        enable = false;
        enableXdgAutostart = true;
      };
    };

    wayland.windowManager.hyprland.settings = with colors; {
      exec-once = import ./conf/execonce.nix;

      env = [
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "XDG_CURRENT_DESKTOP,Hyprland"
      ];

      general = {
        # gaps
        gaps_in = 2;
        gaps_out = 4;

        # border thiccness
        border_size = 2;

        # active border color
        "col.active_border" = "rgb(${rose})";
        "col.inactive_border" = "rgb(${muted})";
      };

      input = {
        kb_layout = "us,ru(phonetic)";
        kb_options = grp:win_space_toggle;
        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
        accel_profile = "flat";
        force_no_accel = false;
      };

      bind = import ./conf/bind.nix {inherit lib pkgs inputs mod;};

      bindm = import ./conf/bindm.nix {inherit mod;};

      dwindle = import ./conf/dwindle.nix;

      master = import ./conf/master.nix;

      decoration = import ./conf/decoration.nix;

      misc = {
        # disable redundant renders
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;

        vfr = false;
        vrr = 2;

        # dpms
        # mouse_move_enables_dpms = true; # enable dpms on mouse/touchpad action
        # key_press_enables_dpms = true; # enable dpms on keyboard action
        disable_autoreload = true; # autoreload is unnecessary on nixos, because the config is readonly anyway
      };

      xwayland = {
        force_zero_scaling = true;
      };

      cursor = {
        no_hardware_cursors = true;
      };

      monitor = ["DP-1,1920x1080@165,0x0,1"];

      layerrule = import ./conf/layerrules.nix;
      workspace = [
        "1,monitor:DP-1"
        "2,monitor:DP-1"
        "3,monitor:DP-1"
        "9,monitor:DP-1"
        "10,monitor:DP-1"
      ];
      windowrulev2 = [
        # only allow shadows for floating windows
        "noshadow, floating:0"
        "tile, title:Cider"

        "idleinhibit focus, class:^(mpv)$"

        "float, title:^(Picture-in-Picture)$"
        "pin, title:^(Picture-in-Picture)$"

        "float,class:udiskie"

        # "workspace special silent,class:^(pavucontrol)$"

        "float, class:^(imv)$"

        # throw sharing indicators away
        "workspace special silent, title:^(Firefox — Sharing Indicator)$"
        "workspace special silent, title:^(.*is sharing (your screen|a window)\.)$"

        # specify what applications start on (at boot and normal startup of the app)
        "workspace 2, class:^(vesktop)$"
        "workspace 3, class:^(cider)$"
        "workspace 4, class:^(zen)"
      ];
    };

    # # fake a tray to let apps start
    # # https://github.com/nix-community/home-manager/issues/2064
    # systemd.user.targets.tray = {
    #   Unit = {
    #     Description = "Home Manager System Tray";
    #     Requires = ["graphical-session-pre.target"];
    #   };
    # };

    systemd.user.services = {
      swaybg = mkService {
        Unit.Description = "Wallpaper chooser";
        Service = {
          ExecStart = "${getExe pkgs.swaybg} -i ${wallpaper}";
          Restart = "always";
        };
      };
    };
  };
}
