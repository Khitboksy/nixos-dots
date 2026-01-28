{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
with lib;
with lib.custom; let
  cfg = config.apps.helpers.waybar;
in {
  options.apps.helpers.waybar = with types; {
    enable = mkBoolOpt false "Enable WayBar";
  };

  config = mkIf cfg.enable {
    xdg.configFile = {
      "waybar/scripts/workspaces" = {
        enable = true;
        source = ./scripts/workspaces;
        recursive = true;
      };
    };

    services.swaync = {
      enable = true;
      style = lib.mkForce ''
        * {
          all: unset;
          font-size: 14px;
          font-family: "Adwaita Sans", "JetBrains Mono Nerd Font";
          transition: 200ms;
        }

        trough highlight {
          background: #cad3f5;
        }

        scale trough {
          margin: 0rem 1rem;
          background-color: #363a4f;
          min-height: 8px;
          min-width: 70px;
        }

        slider {
          background-color: #8aadf4;
        }

        .floating-notifications.background .notification-row .notification-background {
          box-shadow: 0 0 8px 0 rgba(0, 0, 0, 0.8), inset 0 0 0 1px #363a4f;
          border-radius: 12.6px;
          margin: 18px;
          background-color: #24273a;
          color: #cad3f5;
          padding: 0;
        }

        .floating-notifications.background .notification-row .notification-background .notification {
          padding: 7px;
          border-radius: 12.6px;
        }

        .floating-notifications.background .notification-row .notification-background .notification.critical {
          box-shadow: inset 0 0 7px 0 #ed8796;
        }

        .floating-notifications.background .notification-row .notification-background .notification .notification-content {
          margin: 7px;
        }

        .floating-notifications.background .notification-row .notification-background .notification .notification-content .summary {
          color: #cad3f5;
        }

        .floating-notifications.background .notification-row .notification-background .notification .notification-content .time {
          color: #a5adcb;
        }

        .floating-notifications.background .notification-row .notification-background .notification .notification-content .body {
          color: #cad3f5;
        }

        .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * {
          min-height: 3.4em;
        }

        .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action {
          border-radius: 7px;
          color: #cad3f5;
          background-color: #363a4f;
          box-shadow: inset 0 0 0 1px #494d64;
          margin: 7px;
        }

        .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
          box-shadow: inset 0 0 0 1px #494d64;
          background-color: #363a4f;
          color: #cad3f5;
        }

        .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
          box-shadow: inset 0 0 0 1px #494d64;
          background-color: #7dc4e4;
          color: #cad3f5;
        }

        .floating-notifications.background .notification-row .notification-background .close-button {
          margin: 7px;
          padding: 2px;
          border-radius: 6.3px;
          color: #24273a;
          background-color: #ed8796;
        }

        .floating-notifications.background .notification-row .notification-background .close-button:hover {
          background-color: #ee99a0;
          color: #24273a;
        }

        .floating-notifications.background .notification-row .notification-background .close-button:active {
          background-color: #ed8796;
          color: #24273a;
        }

        .control-center {
          box-shadow: 0 0 8px 0 rgba(0, 0, 0, 0.8), inset 0 0 0 1px #363a4f;
          border-radius: 12.6px;
          margin: 18px;
          background-color: #24273a;
          color: #cad3f5;
          padding: 0px;
        }

        .control-center .widget-title > label {
          color: #cad3f5;
          font-size: 1.3em;
        }

        .control-center .widget-title button {
          border-radius: 7px;
          color: #cad3f5;
          background-color: #363a4f;
          box-shadow: inset 0 0 0 1px #494d64;
          padding: 0px;
        }

        .control-center .widget-title button:hover {
          box-shadow: inset 0 0 0 1px #494d64;
          background-color: #5b6078;
          color: #cad3f5;
        }

        .control-center .widget-title button:active {
          box-shadow: inset 0 0 0 1px #494d64;
          background-color: #7dc4e4;
          color: #24273a;
        }

        .control-center .notification-row .notification-background {
          border-radius: 7px;
          color: #cad3f5;
          background-color: #363a4f;
          box-shadow: inset 0 0 0 1px #494d64;
          margin-top: 14px;
        }

        .control-center .notification-row .notification-background .notification {
          padding: 0px;
          border-radius: 7px;
        }

        .control-center .notification-row .notification-background .notification.critical {
          box-shadow: inset 0 0 7px 0 #ed8796;
        }

        .control-center .notification-row .notification-background .notification .notification-content {
          margin: 7px;
        }

        .control-center .notification-row .notification-background .notification .notification-content .summary {
          color: #cad3f5;
        }

        .control-center .notification-row .notification-background .notification .notification-content .time {
          color: #a5adcb;
        }

        .control-center .notification-row .notification-background .notification .notification-content .body {
          color: #cad3f5;
        }

        .control-center .notification-row .notification-background .notification > *:last-child > * {
          min-height: 3.4em;
        }

        .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action {
          border-radius: 7px;
          color: #cad3f5;
          background-color: #181926;
          box-shadow: inset 0 0 0 1px #494d64;
          margin: 7px;
        }

        .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
          box-shadow: inset 0 0 0 1px #494d64;
          background-color: #363a4f;
          color: #cad3f5;
        }

        .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
          box-shadow: inset 0 0 0 1px #494d64;
          background-color: #7dc4e4;
          color: #cad3f5;
        }

        .control-center .notification-row .notification-background .close-button {
          margin: 7px;
          padding: 0px;
          border-radius: 6.3px;
          color: #24273a;
          background-color: #ee99a0;
        }

        .close-button {
          border-radius: 6.3px;
        }

        .control-center .notification-row .notification-background .close-button:hover {
          background-color: #ed8796;
          color: #24273a;
        }

        .control-center .notification-row .notification-background .close-button:active {
          background-color: #ed8796;
          color: #24273a;
        }

        .control-center .notification-row .notification-background:hover {
          box-shadow: inset 0 0 0 1px #494d64;
          background-color: #8087a2;
          color: #cad3f5;
        }

        .control-center .notification-row .notification-background:active {
          box-shadow: inset 0 0 0 1px #494d64;
          background-color: #7dc4e4;
          color: #cad3f5;
        }

        .notification.critical progress {
          background-color: #ed8796;
        }

        .notification.low progress,
        .notification.normal progress {
          background-color: #8aadf4;
        }

        .control-center-dnd {
          margin-top: 5px;
          border-radius: 8px;
          background: #363a4f;
          border: 1px solid #494d64;
          box-shadow: none;
        }

        .control-center-dnd:checked {
          background: #363a4f;
        }

        .control-center-dnd slider {
          background: #494d64;
          border-radius: 8px;
        }

        .widget-dnd {
          margin: 0px;
          font-size: 1.1rem;
        }

        .widget-dnd > switch {
          font-size: initial;
          border-radius: 8px;
          background: #363a4f;
          border: 1px solid #494d64;
          box-shadow: none;
        }

        .widget-dnd > switch:checked {
          background: #363a4f;
        }

        .widget-dnd > switch slider {
          background: #494d64;
          border-radius: 8px;
          border: 1px solid #6e738d;
        }

        .widget-mpris .widget-mpris-player {
          background: #363a4f;
          padding: 0px;
        }

        .widget-mpris .widget-mpris-title {
          font-size: 1.2rem;
        }

        .widget-mpris .widget-mpris-subtitle {
          font-size: 0.8rem;
        }

        .widget-menubar > box > .menu-button-bar > button > label {
          font-size: 3rem;
          padding: 0.5rem 2rem;
        }

        .widget-menubar > box > .menu-button-bar > :last-child {
          color: #ed8796;
        }

        .power-buttons button:hover,
        .powermode-buttons button:hover,
        .screenshot-buttons button:hover {
          background: #363a4f;
        }

        .control-center .widget-label > label {
          color: #cad3f5;
          font-size: 2rem;
        }

        .widget-buttons-grid {
          padding-top: 1rem;
        }

        .widget-buttons-grid > flowbox > flowboxchild > button label {
          font-size: 2.5rem;
        }

        .widget-volume {
          padding-top: 1rem;
        }

        .widget-volume label {
          font-size: 1.5rem;
          color: #7dc4e4;
        }

        .widget-volume trough highlight {
          background: #7dc4e4;
        }

        .widget-backlight trough highlight {
          background: #eed49f;
        }

        .widget-backlight label {
          font-size: 1.5rem;
          color: #eed49f;
        }

        .widget-backlight .KB {
          padding-bottom: 1rem;
        }

        .image {
          padding-right: 0.5rem;
        }
      '';
    };

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      systemd.target = "graphical-session.target";
      style = ''
        /* Custom colors from lib/theme/default.nix */
        @define-color mocha_rosewater ${x colors.mocha_rosewater};
        @define-color mocha_flamingo ${x colors.mocha_flamingo};
        @define-color mocha_pink ${x colors.mocha_pink};
        @define-color mocha_mauve ${x colors.mocha_mauve};
        @define-color mocha_red ${x colors.mocha_red};
        @define-color mocha_maroon ${x colors.mocha_maroon};
        @define-color mocha_peach ${x colors.mocha_peach};
        @define-color mocha_yellow ${x colors.mocha_yellow};
        @define-color mocha_green ${x colors.mocha_green};
        @define-color mocha_teal ${x colors.mocha_teal};
        @define-color mocha_sky ${x colors.mocha_sky};
        @define-color mocha_sapphire ${x colors.mocha_sapphire};
        @define-color mocha_blue ${x colors.mocha_blue};
        @define-color mocha_lavender ${x colors.mocha_lavender};
        @define-color mocha_text ${x colors.mocha_text};
        @define-color mocha_overlay2 ${x colors.mocha_overlay2};
        @define-color mocha_overlay1 ${x colors.mocha_overlay1};
        @define-color mocha_overlay ${x colors.mocha_overlay};
        @define-color mocha_surface2 ${x colors.mocha_surface2};
        @define-color mocha_surface1 ${x colors.mocha_surface1};
        @define-color mocha_surface ${x colors.mocha_surface};
        @define-color mocha_base ${x colors.mocha_base};
        @define-color muted ${x colors.muted};
        @define-color subtle ${x colors.subtle};
        @define-color love ${x colors.love};
        @define-color gold ${x colors.gold};
        @define-color rose ${x colors.rose};
        @define-color pine ${x colors.pine};
        @define-color foam ${x colors.foam};
        @define-color iris ${x colors.iris};
        @define-color highlighthigh ${x colors.highlighthigh};
        @define-color highlightmed ${x colors.highlightmed};
        @define-color highlightlow ${x colors.highlightlow};

        ${builtins.readFile ./style.css}
      '';

      settings = {
        mainBar = {
          layer = "bottom";
          position = "top";
          height = 25;
          spacing = 2;
          exclusive = true;
          "gtk-layer-shell" = true;
          passthrough = false;
          "fixed-center" = true;
          "modules-left" = [
            #  "hyprland/workspaces"
            #  "hyprland/window"
            #"niri/workspaces"
            #"niri/window"
            "cpu"
            "memory"
            "custom/temperature"
            "custom/gpu-usage"
            "custom/gpu-mem"
            "custom/gpu-temp"
          ];

          "modules-center" = [
            #"cpu"
            #"memory"
            #"custom/temperature"

            "custom/workspace-1"
            "custom/workspace-2"
            "custom/workspace-3"
            "custom/workspace-4"
            "custom/workspace-5"
            "clock"
            "clock#simpleclock"
            "custom/workspace-6"
            "custom/workspace-7"
            "custom/workspace-8"
            "custom/workspace-9"
            "custom/workspace-10"

            #"custom/gpu-usage"
            #"custom/gpu-mem"
            #"custom/gpu-temp"

            /**/
          ];
          "modules-right" = [
            "hyprland/window"
            "network#speed"
            "pulseaudio"
            "tray"
          ];

          #"custom/cider" = {
          #  format = "{}";
          #  "return-type" = "json";
          #  "on-click" = "${lib.getExe inputs.ciderd.packages.${pkgs.system}.default} play-pause";
          #  "on-click-right" = "${lib.getExe inputs.ciderd.packages.${pkgs.system}.default} like";
          #  "on-click-middle" = "${lib.getExe inputs.ciderd.packages.${pkgs.system}.default} skip";
          #  exec = "${lib.getExe inputs.ciderd.packages.${pkgs.system}.default} monitor";
          #};

          mpris = {
            player = "spotify";
            "dynamic-order" = ["artist" "title"];
            format = "{player_icon}{dynamic}";
            "format-paused" = "{status_icon}<i>{dynamic}</i>";
            "status-icons" = {
              paused = "";
            };
            "player-icons" = {
              default = "";
            };
            max-length = 45;
            min-length = 15;
          };

          /*
            "hyprland/workspaces" = {
            "on-click" = "activate",<F5>
            format = "{id}";
            "all-outputs" = true;
            "disable-scroll" = false;
            "active-only" = false;
          };
          */

          # // ── Workspaces (custom scripts) -- Stolen from Pewdiepie-Archdaemon's waybar config
          "custom/workspace-10" = {
            exec = "~/.config/waybar/scripts/workspaces/workspace-0.sh";
            interval = 1;
            on-click = "hyprctl dispatch workspace 10";
            tooltip = "Switch to workspace 10";
          };
          "custom/workspace-1" = {
            exec = "~/.config/waybar/scripts/workspaces/workspace-1.sh";
            interval = 1;
            on-click = "hyprctl dispatch workspace 1";
            tooltip = "Switch to workspace 1";
          };
          "custom/workspace-2" = {
            exec = "~/.config/waybar/scripts/workspaces/workspace-2.sh";
            interval = 1;
            on-click = "hyprctl dispatch workspace 2";
            tooltip = "Switch to workspace 2";
          };
          "custom/workspace-3" = {
            exec = "~/.config/waybar/scripts/workspaces/workspace-3.sh";
            interval = 1;
            on-click = "hyprctl dispatch workspace 3";
            tooltip = "Switch to workspace 3";
          };
          "custom/workspace-4" = {
            exec = "~/.config/waybar/scripts/workspaces/workspace-4.sh";
            interval = 1;
            on-click = "hyprctl dispatch workspace 4";
            tooltip = "Switch to workspace 4";
          };
          "custom/workspace-5" = {
            exec = "~/.config/waybar/scripts/workspaces/workspace-5.sh";
            interval = 1;
            on-click = "hyprctl dispatch workspace 5";
            tooltip = "Switch to workspace 5";
          };
          "custom/workspace-6" = {
            exec = "~/.config/waybar/scripts/workspaces/workspace-6.sh";
            interval = 1;
            on-click = "hyprctl dispatch workspace 6";
            tooltip = "Switch to workspace 6";
          };
          "custom/workspace-7" = {
            exec = "~/.config/waybar/scripts/workspaces/workspace-7.sh";
            interval = 1;
            on-click = "hyprctl dispatch workspace 7";
            tooltip = "Switch to workspace 7";
          };
          "custom/workspace-8" = {
            exec = "~/.config/waybar/scripts/workspaces/workspace-8.sh";
            interval = 1;
            on-click = "hyprctl dispatch workspace 8";
            tooltip = "Switch to workspace 8";
          };
          "custom/workspace-9" = {
            exec = "~/.config/waybar/scripts/workspaces/workspace-9.sh";
            interval = 1;
            on-click = "hyprctl dispatch workspace 9";
            tooltip = "Switch to workspace 9";
          };
          "hyprland/window" = {
            format = "{title}";
            max-length = 30;
            min-length = 5;
          };

          "network#speed" = {
            interval = 1;
            format = "{ifname}%%";
            format-wifi = " {bandwidthDownBytes}  {bandwidthUpBytes}";
            format-ethernet = " {bandwidthDownBytes}  {bandwidthUpBytes}";
            format-disconnected = "󰌙";
            tooltip-format = "{ipaddr}";
            format-linked = "󰈁 {ifname} (No IP)";
            tooltip-format-wifi = "{essid} {icon} {signalStrength}%";
            tooltip-format-ethernet = "{ifname} 󰌘";
            tooltip-format-disconnected = "󰌙 Disconnected";
            format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
          };

          # GPU Modules
          "custom/gpu-temp" = {
            interval = 10;
            exec = "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits";
            format = "{}°C";
            tooltip = false;
          };

          "custom/gpu-mem" = {
            interval = 10;
            exec = "nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits | awk '{printf \"%.1f\", $1/1024}'";
            format = "{}Gi";
            tooltip = false;
          };

          "custom/gpu-usage" = {
            interval = 2;
            exec = "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits";
            format = "{}%";
            tooltip = false;
          };

          # CPU Modules
          cpu = {
            format = "{usage}%";
            tooltip = true;
            interval = 1;
          };

          memory = {
            format = "{used:0.1f}Gi";
          };

          "temperature" = {
            hwmon-path-abs = "/sys/class/hwmon/hwmon2/temp1_input";
            /*
               input_filename = "temp1_input";
            critical-threshold = 85;
            */
            format = "{temperatureC}°C";
            /*
            format-critical = "{temperatureC}°C";
            */
          };

          tray = {
            "show-passive-items" = true;
            spacing = 10;
          };

          "clock#simpleclock" = {
            tooltip = false;
            format = "{:%H:%M}";
          };

          clock = {
            format = "{:L%a %d %b}";
            calendar = {
              format = {
                days = "<span weight='normal'>{}</span>";
                months = "<span color='#cdd6f4'><b>{}</b></span>";
                today = "<span color='#f38ba8' weight='700'><u>{}</u></span>";
                weekdays = "<span color='#f9e2af'><b>{}</b></span>";
                weeks = "<span color='#a6e3a1'><b>W{}</b></span>";
              };
              mode = "month";
              "mode-mon-col" = 1;
              "on-scroll" = 1;
            };
            "tooltip-format" = "<span color='#cdd6f4' font='Lexend 16'><tt><small>{calendar}</small></tt></span>";
          };

          pulseaudio = {
            format = "{volume}%";
            "format-muted" = "muted";
            "format-icons" = {
              headphone = "";
              default = [" " " " " "];
            };
            "on-click" = "pwvucontrol";
            /*
            max-length = 4;
            */
            /*
            min-length = 2;
            */
          };

          "custom/sep" = {
            format = "|";
            tooltip = false;
          };

          "custom/power" = {
            tooltip = false;
            "on-click" = "wlogout -p layer-shell &";
            format = "⏻";
          };

          "custom/notification" = {
            escape = true;
            exec = "swaync-client -swb";
            "exec-if" = "which swaync-client";
            format = "{icon}";
            "format-icons" = {
              none = "󰅺";
              notification = "󰡟";
            };
            "on-click" = "sleep 0.1 && swaync-client -t -sw";
            "return-type" = "json";
            tooltip = false;
          };

          "custom/temperature" = {
            interval = 5;
            exec = "cat /sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon2/temp1_input | awk '{printf \"%d°C\", $1/1000}'";
            format = "{}";
          };
        };
      };
    };
  };
}
