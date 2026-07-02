{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.custom;
let
  cfg = config.apps.term.kitty;
in
{
  options.apps.term.kitty = with types; {
    enable = mkBoolOpt false "Enable Kitty terminal";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (writeShellScriptBin "kitty-launcher" ''
        MARKER="''${XDG_RUNTIME_DIR}/kitty-tmux-active"

        if [ -f "$MARKER" ]; then
            KITTY_FLOAT=1 kitty --class kitty-float "$@" &
            KITTY_PID=$!
            sleep 0.05
            ${pkgs.niri}/bin/niri msg action center-window
            ${pkgs.niri}/bin/niri msg action move-floating-window --x +0 --y -100
            # Force resize via kitty remote control
            ${pkgs.kitty}/bin/kitten @ resize-window --width 50c --height 14c 2>/dev/null || true
            wait $KITTY_PID
        else
            touch "$MARKER"
            trap 'rm -f "$MARKER"' EXIT INT TERM
            kitty -e tmux -u new -A -s main
        fi
      '')
      iosevka
      jetbrains-mono
      noto-fonts-color-emoji
      nerd-fonts.iosevka-term
      nerd-fonts.jetbrains-mono
    ];

    programs.kitty = {
      package = pkgs.kitty;
      enable = true;

      extraConfig = ''
        cursor_trail_decay 0.1 0.4
        allow_remote_control socket
        clipboard_control write-clipboard write-primary read-clipboard read-primary
      '';

      settings = {
        font_family = "Iosevka Term Nerd Font";
        font_size = 12;
        bold_font = "Iosevka Term Nerd Font Bold";
        italic_font = "Iosevka Term Nerd Font Italic";
        bold_italic_font = "Iosevka Term Nerd Font Bold Italic";

        font_features = "+Iosevka";

        disable_ligatures = "never";
        disable_ligatures_in_monitored_types = "all";

        window_padding_width = 12;
        window_padding_height = 12;

        background_opacity = 0.8;

        macos_option_as_alt = true;
        macos_titlebar_color = "background";

        wayland_enable = true;
        linux_bell_command = "";

        repaint_delay = 10;
        input_delay = 3;
        sync_to_cursor = "no";

        remember_window_size = false;
        initial_window_width = 240;
        initial_window_height = 250;

        scrollback_lines = 10000;

        confirm_window_close = 0;
        startup_session = "none";

        foreground = "${colors.text.hex}";
        background = "${colors.mantle.hex}";
        selection_foreground = "${colors.base.hex}";
        selection_background = "${colors.rosewater.hex}";
        cursor = "${colors.rosewater.hex}";
        cursor_text_color = "${colors.base.hex}";
        cursor_trail = 3;
        scrollbar_handle_color = "${colors.overlay2.hex}";
        scrollbar_track_color = "${colors.surface1.hex}";
        url_color = "${colors.rosewater.hex}";

        active_border_color = "${colors.lavender.hex}";
        inactive_border_color = "${colors.overlay0.hex}";
        bell_border_color = "${colors.yellow.hex}";

        active_tab_foreground = "${colors.crust.hex}";
        active_tab_background = "${colors.mauve.hex}";
        inactive_tab_foreground = "${colors.text.hex}";
        inactive_tab_background = "${colors.mantle.hex}";
        tab_bar_background = "${colors.crust.hex}";

        mark1_foreground = "${colors.base.hex}";
        mark1_background = "${colors.lavender.hex}";
        mark2_foreground = "${colors.base.hex}";
        mark2_background = "${colors.mauve.hex}";
        mark3_foreground = "${colors.base.hex}";
        mark3_background = "${colors.sapphire.hex}";

        color0 = "${colors.surface1.hex}";
        color8 = "${colors.surface2.hex}";
        color1 = "${colors.red.hex}";
        color9 = "${colors.red.hex}";
        color2 = "${colors.green.hex}";
        color10 = "${colors.green.hex}";
        color3 = "${colors.yellow.hex}";
        color11 = "${colors.yellow.hex}";
        color4 = "${colors.blue.hex}";
        color12 = "${colors.blue.hex}";
        color5 = "${colors.pink.hex}";
        color13 = "${colors.pink.hex}";
        color6 = "${colors.teal.hex}";
        color14 = "${colors.teal.hex}";
        color7 = "${colors.subtext1.hex}";
        color15 = "${colors.subtext0.hex}";
      };
    };

    # Override system desktop entry so rofi launches kitty-launcher instead of bare kitty
    xdg.desktopEntries."kitty" = {
      name = "Kitty";
      exec = "kitty-launcher";
      terminal = false;
      categories = [
        "System"
        "TerminalEmulator"
      ];
      mimeType = [
        "text/plain"
        "x-scheme-handler/terminal"
      ];
    };
  };
}
