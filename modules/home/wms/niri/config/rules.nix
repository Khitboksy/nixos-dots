{
  # Window rules
  window-rule = [
    {
      match = [
        { _props.app-id = "^Bitwarden$"; }
        { _props.title = "^Extension:.*Bitwarden.*Zen Browser$"; }
        { _props.app-id = "^signal$"; }
        { _props.app-id = "^vesktop$"; }
      ];
      block-out-from = [ "screen-capture" ];
    }
    {
      opacity = 0.8;
      background-effect = {
        blur = true;
      };
      geometry-corner-radius = [
        12
        12
        12
        12
      ];
      clip-to-geometry = true;
      draw-border-with-background = false;
    }
    {
      match._props.app-id = "^steam$";
      exclude._props.title = "^Steam$";
      open-focused = false;
      open-floating = true;
      default-floating-position._props = {
        relative-to = "bottom-right";
        x = 16;
        y = 16;
      };
    }
    {
      match._props.title = "^Steam$";
      open-floating = true;
      open-focused = true;
    }

    {
      match._props.title = "^Deadlock$";
      open-on-workspace = "games";
      open-maximized-to-edges = true;
      open-focused = true;
    }
    {
      match._props.app-id = "^zen$";
      draw-border-with-background = false;
      open-focused = true;
    }
    {
      match._props = {
        app-id = "^zen$";
        at-startup = true;
      };
      open-on-workspace = "browser";
      open-maximized = true;
      open-focused = false;
    }
    {
      match._props.title = "^Extension:.*Bitwarden.*Zen Browser$";
      open-floating = true;
      open-focused = true;
    }

    {
      match._props.app-id = "^mpv$";
      open-maximized = true;
      open-focused = true;
      opacity = 1.0;
    }

    {
      match._props.app-id = "^vesktop";
      open-on-workspace = "chat";
      open-maximized = true;
      open-focused = false;
    }
    {
      match._props.app-id = "^kitty$";
      opacity = 1.0;
      open-focused = true;
      open-maximized = true;
      open-on-workspace = "code";
    }
    {
      match._props.app-id = "^kitty-float$";
      opacity = 1.0;
      open-focused = true;
      open-floating = true;
      default-column-width = {
        proportion = 0.4;
      };
      default-window-height = {
        proportion = 0.3;
      };
    }
    {
      match._props.app-id = "^kitty-palette$";
      opacity = 1.0;
      open-focused = true;
      open-floating = true;
      default-column-width = {
        proportion = 0.7;
      };
      default-window-height = {
        proportion = 0.90;
      };
    }
  ];

  # Layer rules
  layer-rule = [
    # Block notifications from screen capture
    {
      match._props.namespace = "notifications";
      block-out-from = [ "screen-capture" ];
    }
    # Wallpaper — matches swaybg's hardcoded namespace
    {
      match._props.namespace = "^wallpaper$";
      place-within-backdrop = true;
    }
    {
      match._props.namespace = "^noctalia-(background|bar|launcher-overlay|dock)-.*$";
      background-effect = {
        xray = false;
      };
    }
  ];
}
