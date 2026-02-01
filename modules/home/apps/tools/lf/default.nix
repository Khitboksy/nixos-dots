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
    #xdg.configFile."lf/icons".source = ./icons;
    programs.lf = {
      enable = true;
      commands = {
        #dragon-out = ''%${pkgs.dragon-drop}/bin/xdragon -a -x "$fx"'';
        #editor-open = ''$$EDITOR $f'';
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
        "Km" = "maps"; # List normal mode mappings
        "Kc" = "cmaps"; # List command mode mappings

        #do = "dragon-out";

        gh = "cd ~";
        gb = "cd ..";

        ee = "editor-open";
        #V = ''$${pkgs.bat}/bin/bat --paging=always --theme=gruvbox "$f"'';

        # ...
      };

      settings = {
        preview = true;
        hidden = true;
        drawbox = false;
        icons = false;
        ignorecase = true;
      };
      extraConfig = let
        previewer = pkgs.writeShellScriptBin "pv.sh" ''
          file=$1
          w=$2
          h=$3
          x=$4
          y=$5

          if [[ "$( ${pkgs.file}/bin/file -Lb --mime-type "$file")" =~ ^image ]]; then
              ${pkgs.kitty}/bin/kitty +kitten icat --silent --stdin no --transfer-mode file --place "''${w}x''${h}@''${x}x''${y}" "$file" < /dev/null > /dev/tty
              exit 1
          fi

          ${pkgs.pistol}/bin/pistol "$file"
        '';
        cleaner = pkgs.writeShellScriptBin "clean.sh" ''
          ${pkgs.kitty}/bin/kitty +kitten icat --clear --stdin no --silent --transfer-mode file < /dev/null > /dev/tty
        '';
      in ''
        set cleaner ${cleaner}/bin/clean.sh
        set previewer ${previewer}/bin/pv.sh
      '';
    };
  };
}
# ...

