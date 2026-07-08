{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
with lib.custom;
let
  cfg = config.apps.term.tuis.yazi;
  system = pkgs.stdenv.hostPlatform.system;
in
{
  options.apps.term.tuis.yazi = with types; {
    enable = mkBoolOpt false "Enable Yazi";
  };

  config = mkIf cfg.enable {

    apps.term.tuis.mpv.enable = true;

    xdg.configFile = {
      "yazi/init.lua".text = ''
        -- SSH host indicator for Yazi — shows "ssh@hostname" in the header
        -- when connected via SSH. Managed by Nix.

        Header:children_add(function()
            if ya.target_family() ~= "unix" then
                return ""
            end

            local ssh = os.getenv("SSH_CONNECTION")
            if not ssh then
                return ""
            end

            local host = ya.host_name()
            if host == "" then
                return ""
            end

            return ui.Line {
                ui.Span("ssh@"):fg("${colors.yellow.hex}"),
                ui.Span(host):fg("${colors.sapphire.hex}"),
                ui.Span(" "),
            }
        end, 500, Header.LEFT)
      '';
      "yazi/theme.toml".text = (import ./config/themes/helios-yaziTheme.nix) { inherit lib; };
      "yazi/helios.tmTheme".text = (import ./config/themes/helios-yaziTM.nix) { inherit lib; };
      "ytfzf/conf.sh".text = ''
        YTFZF_DOWNLOAD_DIR="/mnt/nix-data/media/ytfzf"
        YTFZF_CACHE_DIR="/mnt/nix-data/media/ytfzf/cache"
      '';
    };

    programs.yazi = {
      enable = true;
      package = inputs.yazi.packages.${system}.yazi;

      plugins = (import ./config/yazi-plugins.nix) { inherit pkgs; };
      keymap = import ./config/yazi-binds.nix;

      enableBashIntegration = false;
      enableZshIntegration = false;
      enableFishIntegration = true;

      shellWrapperName = "y";

      settings = {

        opener = {
          viu = [
            {
              run = "viu --transparent %s";
              block = true;
              desc = "View image (viu)";
            }
          ];
          video = [
            {
              run = "mpv %s";
              block = true;
              desc = "Play video (mpv)";
            }
          ];
        };

        open = {
          prepend_rules = [
            {
              mime = "image/*";
              use = "viu";
            }
            {
              mime = "video/*";
              use = "video";
            }
          ];
        };
        yazi = {
          mouse = true;
        };

        manager = {
          show_hidden = true;
          ignore = [
            ".git"
            "node_modules"
            ".cache"
          ];
          sort_by = "natural";
          sort_sensitive = false;
          sort_reverse = false;
          sort_dir_first = true;
          win_border = "none";
          content_align = "start";
          cursor = "underline";
          cursor_blink = "never";
          inline_prompt = true;
        };

        preview = {
          image = {
            backend = "kitty";
            scale = 1.0;
          };
        };

        tasks = {
          macro_workers = 10;
          micro_workers = 5;
        };
      };
    };

    home.packages = with pkgs; [
      ripdrag
      viu
      ytfzf
    ];

  };
}
