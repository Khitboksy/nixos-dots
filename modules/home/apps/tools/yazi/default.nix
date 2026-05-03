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
  cfg = config.apps.tools.yazi;
  system = pkgs.stdenv.hostPlatform.system;
in
{
  options.apps.tools.yazi = with types; {
    enable = mkBoolOpt false "Enable Yazi";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      yaziPlugins.bookmarks
    ];

    programs.yazi = {
      enable = true;
      package = inputs.yazi.packages.${system}.yazi;

      enableBashIntegration = false;
      enableZshIntegration = false;
      enableFishIntegration = true;

      shellWrapperName = "y";

      settings = {
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

      plugins = {
        bookmarks = pkgs.yaziPlugins.bookmarks;
      };
    };

    xdg.configFile."yazi/theme.toml".text = (import ./themes/helios.nix) { inherit lib; };
    xdg.configFile."yazi/helios.tmTheme".text = (import ./themes/heliostm.nix) { inherit lib; };
  };
}
