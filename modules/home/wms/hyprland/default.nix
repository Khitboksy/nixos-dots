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
  modshift = "${mod}SHIFT";

  # binds $mod + [shift +] {1..10} to [move to] workspace {1..10} (stolen from fufie)
  workspaces = builtins.concatLists (builtins.genList (
      x: let
        ws = let
          c = (x + 1) / 10;
        in
          builtins.toString (x + 1 - (c * 10));
      in [
        "${mod}, ${ws}, workspace, ${toString (x + 1)}"
        "${mod} SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
      ]
    )
    10);
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
      exec-once = [
        # "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        # "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "zen"
        "vesktop"
        "spotify"
        "networkmanagerapplet"
        "[workspace 9 silent] kitty"
        "[workspace 9 silent] kitty"
        "[workspace 9 silent] kitty"
        "[workspace 10 silent] kitty"
      ];

      env = [
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "XDG_CURRENT_DESKTOP,Hyprland"
      ];

      bind =
        [
          ''${mod},R,exec,${lib.getExe pkgs.kitty}''
          ''${mod},Z,exec,${lib.getExe inputs.zen-browser.packages.${pkgs.system}.beta}''

          "${mod},D,exec,fuzzel"
          "${mod},Q,killactive"
          "${mod},M,exit"
          "${mod},P,pseudo"

          "${mod},J,togglesplit,"

          "${mod},T,togglegroup," # group focused window
          "${modshift},G,changegroupactive," # switch within the active group
          "${mod},V,togglefloating," # toggle floating for the focused window
          "${mod},F,fullscreen," # fullscreen focused window

          # workspace controls
          "${modshift},right,movetoworkspace,+1" # move focused window to the next ws
          "${modshift},left,movetoworkspace,-1" # move focused window to the previous ws
          "${mod},mouse_down,workspace,e+1" # move to the next ws
          "${mod},mouse_up,workspace,e-1" # move to the previous ws
          "${modshift},O,exec,wl-ocr"
          "${mod},S,exec,${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp})\" - | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png"

          "${mod},Period,exec, tofi-emoji"

          "${modshift},L,exec,swaylock --grace 0" # lock screen
        ]
        ++ workspaces;

      bindm = [
        "${mod},mouse:272,movewindow"
        "${mod},mouse:273,resizewindow"
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

      dwindle = {
        force_split = 2;
      };

      decoration = {
        # fancy corners
        rounding = 6;
        # blur
        blur = {
          enabled = true;
          size = 4;
          passes = 2;
          new_optimizations = 1;
          contrast = 1;
          brightness = 1;
        };

        shadow = {
          # shadow config
          enabled = false;
          # range = 60;
          # render_power = 5;
          # color = "rgba(07061f29)";
        };
      };

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

      monitor = ["DP-1,1920x1080@165,0x0,1" "DP-2,1366x768@60,1920x600,1"];

      layerrule = [
        "blur, ^(gtk-layer-shell)$"
        "blur, ^(launcher)$"
        "ignorezero, ^(gtk-layer-shell)$"
        "ignorezero, ^(launcher)$"
        "blur, notifications"
        "ignorezero, notificatios"
        "blur, bar"
        "ignorezero, bar"
        "ignorezero, ^(gtk-layer-shell|anyrun)$"
        "blur, ^(gtk-layer-shell|anyrun)$"
        "noanim, launcher"
        "noanim, bar"
      ];
      workspace = [
        "1,monitor:DP-1"
        "2,monitor:DP-2"
        "3,monitor:DP-2"
        "9,monitor:DP-1"
        "10,monitor:DP-2"
      ];
      windowrulev2 = [
        # only allow shadows for floating windows
        "noshadow, floating:0"
        "tile, title:Spotify"

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
        "workspace 3, class:^(spotify)$"
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
