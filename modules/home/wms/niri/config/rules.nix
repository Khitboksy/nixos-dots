{
  # Window rules
  window-rule = [
    # Zen browser
    {
      match._props.app-id = "^zen$";
      draw-border-with-background = false;
      open-focused = false;
      open-maximized = true;
    }
    {
      match = [
        { _props.app-id = "^zen$"; }
      ];
    }
    {
      match = [
        { _props.app-id = "^zen$"; }
        { _props.at-startup = true; }
      ];
      open-on-workspace = "browser";
    }

    # Bitwarden, Signal, Vesktop - block from screen capture
    {
      match = [
        { _props.app-id = "^Bitwarden$"; }
        { _props.app-id = "^signal$"; }
        { _props.app-id = "^vesktop$"; }
      ];
      block-out-from = [ "screen-capture" ];
    }

    # Steam
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

    # Gamescope
    {
      match._props.app-id = "^gamescope$";
      open-on-workspace = "games";
      open-maximized-to-edges = true;
      open-focused = true;
    }

    # Vesktop
    {
      match._props.title = "^Vesktop$";
      open-on-workspace = "chat";
      open-maximized = true;
      open-focused = false;
    }

    # Kitty
    {
      match._props.title = "^fish$";
      opacity = 1.0;
      open-focused = true;
      open-floating = true;
    }
    {
      match = [
        { _props.title = "^fish$"; }
        { _props.at-startup = true; }
      ];
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
