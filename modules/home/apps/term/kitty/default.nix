{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.custom; let
  cfg = config.apps.term.kitty;
in {
  options.apps.term.kitty = with types; {
    enable = mkBoolOpt false "Enable Kitty terminal";
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      package = pkgs.kitty;
      enable = true;

      settings = {
        font_family = "Iosevka";
        font_size = 14;
        bold_font = "Iosevka Bold";
        italic_font = "Iosevka Italic";
        bold_italic_font = "Iosevka Bold Italic";

        disable_ligatures = "never";
        disable_ligatures_in_monitored_types = "all";

        window_padding_width = 14;
        window_padding_height = 14;

        background_opacity = 0.8;

        macos_option_as_alt = true;
        macos_titlebar_color = "background";

        wayland_enable = true;
        linux_bell_command = "";

        repaint_delay = 10;
        input_delay = 3;
        sync_to_cursor = "no";

        scrollback_lines = 10000;

        confirm_window_close = 0;
        startup_session = "none";
      };
    };
  };
}
