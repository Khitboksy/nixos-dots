{
  # Window rules
  window-rule = [
    {
      match = [
        { _props.app-id = "^Bitwarden$"; }
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
      match = [
        { _props.app-id = "^Bitwarden$"; }
        { _props.app-id = "^signal$"; }
        { _props.app-id = "^vesktop$"; }
      ];
      block-out-from = [ "screen-capture" ];
    }
    {
      match._props.app-id = "^steam$";
      exclude._props.title = "^Steam$";
      open-focused = false;
      default-floating-position._props = {
        relative-to = "bottom-right";
        x = 16;
        y = 16;
      };
    }
    {
      match._props.app-id = "^steam$";
      open-floating = true;
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
      open-maximized = true;
    }
    {
      match = [
        { _props.app-id = "^zen$"; }
        { _props.at-startup = true; }
      ];
      open-on-workspace = "browser";
      open-focused = false;
    }

    {
      match._props.app-id = "^mpv$";
      open-maximized = true;
      open-focused = true;
      opacity = 1.0;
    }

    {
      match._props.app-id = "^vesktop$";
      open-on-workspace = "chat";
      open-maximized = true;
      open-focused = false;
    }
    {
      match._props.app-id = "^kitty$";
      opacity = 1.0;
      open-focused = true;
      open-floating = true;
    }
    {
      match = [
        { _props.app-id = "^kitty$"; }
        { _props.at-startup = true; }
      ];
      opacity = 1.0;
      open-on-workspace = "code";
      open-floating = false;
      open-maximized = true;
    }
  ];

  # Layer rules
  layer-rule = [
    # Block notifications from screen capture
    {
      match._props.namespace = "notifications";
      block-out-from = [ "screen-capture" ];
    }
    # Wallpaper
    {
      match._props.namespace = "^wallpaper&";
      place-within-backdrop = true;
    }
  ];
}
