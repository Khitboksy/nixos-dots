{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with lib.custom; let
  cfg = config.apps.tools.lf;
in {
  options.apps.tools.lf = with types; {
    enable = mkBoolOpt false "Enable LF";
  };

  config = mkIf cfg.enable {
    xdg.configFile."lf/icons".source = ./icons;
    programs.lf = {
      enable = true;
      commands = {
        dragon-out = ''%${pkgs.dragon-drop}/bin/xdragon -a -x "$fx"'';
        editor-open = ''$$EDITOR $f'';
        mkdir = ''
          ''${{
            printf "Directory Name: "
            read DIR
            mkdir $DIR
          }}
        '';
      };

      keybindings = {
        "\\\"" = "";
        o = "";
        c = "mkdir";
        "." = "set hidden!";
        "`" = "mark-load";
        "\\'" = "mark-load";
        "<enter>" = "open";
        Km = "maps"; # List normal mode mappings
        Kc = "cmaps"; # List command mode mappings

        do = "dragon-out";

        gh = "cd ~";
        gb = "cd ..";

        ee = "editor-open";
        V = ''$${pkgs.bat}/bin/bat --paging=always --theme=gruvbox "$f"'';

        # ...
      };

      settings = {
        preview = true;
        hidden = true;
        drawbox = true;
        icons = true;
        ignorecase = true;
      };
    };
  };

  # ...
}
