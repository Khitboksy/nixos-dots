{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.custom; let
  cfg = config.apps.games.mangohud;
  stripHash = hex: builtins.substring 1 (builtins.stringLength hex - 1) hex;
  mkWrapper = profile: let
    homeDir = config.home.homeDirectory;
    confPath = "${homeDir}/.config/MangoHud/${profile}.conf";
  in ''
    #!${pkgs.bash}/bin/bash
    export MANGOHUD_CONFIGFILE="${confPath}"
    exec ${pkgs.mangohud}/bin/mangohud "$@"
  '';
in {
  options.apps.games.mangohud = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable MangoHud";
    };

    profiles = mkOption {
      type = types.attrsOf types.str;
      default = {
        def = ''
          font_size=18
          transparent_background
          frame_timing=0
          text_color=${stripHash colors.text.hex}

          fps_text=FPS
          fps_color_change
          fps_value=30,120,165
          fps_color=${stripHash colors.red.hex},${stripHash colors.yellow.hex},${stripHash colors.sapphire.hex}
          engine_color=${stripHash colors.pink.hex}

          cpu_text=R7 5800x
          cpu_load_change
          cpu_load_value=30,60,90
          cpu_load_color=${stripHash colors.sapphire.hex},${stripHash colors.yellow.hex},${stripHash colors.red.hex}
          cpu_color=${stripHash colors.pink.hex}

          gpu_text=RTX 2080
          gpu_load_change
          gpu_load_value=30,60,90
          gpu_load_color=${stripHash colors.sapphire.hex},${stripHash colors.yellow.hex},${stripHash colors.red.hex}
          gpu_color=${stripHash colors.pink.hex}

          fps
          frametime
          frame_timing=0
          cpu_stats
          cpu_temp
          gpu_stats
          gpu_temp
        '';
        fps = ''
          font_size=18
          transparent_background
          text_color=${stripHash colors.text.hex}

          fps_text=FPS
          fps_color_change
          fps_value=30,120,165
          fps_color=${stripHash colors.red.hex},${stripHash colors.yellow.hex},${stripHash colors.sapphire.hex}
          engine_color=${stripHash colors.pink.hex}

          fps_only
        '';
        testing = ''
          font_size=18
          transparent_background
          frame_timing=0
          text_color=${stripHash colors.text.hex}

          fps_text=FPS
          fps_color_change
          fps_value=30,120,165
          fps_color=${stripHash colors.red.hex},${stripHash colors.yellow.hex},${stripHash colors.sapphire.hex}
          engine_color=${stripHash colors.pink.hex}
          frametime_color=${stripHash colors.green.hex}

          cpu_text=R7 5800x
          cpu_load_change
          cpu_load_value=30,60,90
          cpu_load_color=${stripHash colors.sapphire.hex},${stripHash colors.yellow.hex},${stripHash colors.red.hex}
          cpu_color=${stripHash colors.pink.hex}
          ram_color=${stripHash colors.pink.hex}

          gpu_text=RTX 2080
          gpu_load_change
          gpu_load_value=30,60,90
          gpu_load_color=${stripHash colors.sapphire.hex},${stripHash colors.yellow.hex},${stripHash colors.red.hex}
          gpu_color=${stripHash colors.pink.hex}
          vram_color=${stripHash colors.pink.hex}

          winesync
          wine_color=${stripHash colors.pink.hex}

          fps
          frametime
          frame_timing

          cpu_stats
          cpu_temp
          cpu_mhz
          ram

          gpu_stats
          gpu_temp
          gpu_core_clock
          vram

        '';
      };
      description = "MangoHud profiles.";
    };

    defaultProfile = mkOption {
      type = types.str;
      default = "def";
      description = "Profile used by MangoHud by default";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      mangohud
      nerd-fonts.iosevka
    ];

    home.file = foldl' recursiveUpdate {} (mapAttrsToList (name: content: {
        ".local/bin/mangohud-${name}" = {
          text = mkWrapper name;
          executable = true;
        };
        ".config/MangoHud/${name}.conf" = {
          text = content;
          executable = false;
        };
      })
      cfg.profiles);
  };
}
