{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.apps.helpers.rofi;
in

{

  options.apps.helpers.rofi = with types; {
    enable = mkBoolOpt false "Enable Rofi";
  };

  config = mkIf cfg.enable {

    programs.rofi = {
      enable = true;
      package = pkgs.rofi;

      font = "Iosevka Bold 16";

      extraConfig = {
        show-icons = true;
        drun-display-format = "{name}";

        modi = "drun";
        drun-match-fields = "name";
        matching = "fuzzy";
        normalize-match = true;
        sorting-method = "fzf";
      };

      theme =

        let
          inherit (config.lib.formats.rasi) mkLiteral;
        in

        {

          "*" = {
            background-color = mkLiteral (colors.mantle.hex + "cc");
            foreground-color = mkLiteral colors.blue.hex;
            border-color = mkLiteral colors.mauve.hex;
            spacing = 2;
          };

          window = {
            text-alignment = mkLiteral "center";
            location = mkLiteral "center";
            anchor = mkLiteral "center";
            width = mkLiteral "350";
            height = mkLiteral "250";
            border = mkLiteral "4px";
            "border-radius" = mkLiteral "12";
          };

          mainbox = {
            padding = 0;
          };

          inputbar = {
            children = mkLiteral "[ \"entry\" ]";
          };

          prompt = {
            enabled = false;
          };

          entry = {
            "text-color" = mkLiteral colors.mauve.hex;
            "placeholder-color" = mkLiteral colors.yellow.hex;
            margin = mkLiteral "0px 90px 5px 90px";
            padding = mkLiteral "2px 8px 2px 8px";
            border = mkLiteral "0px 2px 2px 2px";
            "border-radius" = mkLiteral "2px 2px 8px 8px";
            "border-color" = mkLiteral colors.mauve.hex;
          };

          listview = {
            spacing = 1;
            scrollbar = false;
            padding = mkLiteral "0px 10px 0px 10px";
            margin = mkLiteral "0px 40px 10px 40px";
          };

          element = {
            padding = 2;
          };

          "element selected.normal" = {
            "text-color" = mkLiteral colors.mauve.hex;
            "background-color" = "transparent";
          };

          "element selected.active" = {
            "text-color" = mkLiteral colors.mauve.hex;
            "background-color" = "transparent";
          };

          "element normal.normal" = {
            "text-color" = mkLiteral colors.blue.hex;
            "background-color" = "transparent";
          };

          "element-text" = {
            "text-color" = mkLiteral colors.blue.hex;
            highlight = mkLiteral colors.green.hex;
          };

        };
    };
  };
}
