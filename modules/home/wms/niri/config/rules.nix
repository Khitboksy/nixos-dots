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

    ## FUCK STEAM FR
    # Fix steams jank ass id's/titles so things open more naturally
    {
      # Notifications like ur friend playing a game
      match._props.title = "^notificationtoasts_1_desktop$";
      open-focused = false;
      open-floating = true;
      default-floating-position._props = {
        relative-to = "bottom-right";
        x = 12;
        y = 12;
      };
    }
    {
      # The steam page itself
      match._props.title = "^Steam$";
      open-focused = false;
      open-on-workspace = "games";
      default-column-width = {
        proportion = 0.8;
      };
    }
    {
      # Friends list next to it
      match._props.title = "^Friends List$";
      open-focused = false;
      open-on-workspace = "games";
      default-column-width = {
        proportion = 0.2;
      };
    }
    {
      # Startup/Shutdown
      match._props.title = "^(Sign in to Steam|Shutdown)$";
      open-focused = false;
      open-floating = true;
      open-on-workspace = "games";
    }
    {
      # The only way i can figure out how to get just chats
      match._props.app-id = "^steam$";
      exclude._props.title = "^(Sign in to Steam|Shutdown|Friends List|Steam|notificationtoasts_1_desktop)$";
      open-focused = false;
      open-floating = false;
      open-on-workspace = "chat";
      default-column-width = {
        proportion = 0.5;
      };
    }

    {
      match._props.title = "^Deadlock$";
      open-on-workspace = "games";
      open-maximized-to-edges = true;
      open-focused = true;
    }
    {
      match._props.app-id = "^zen(-beta)?$";
      draw-border-with-background = false;
      open-focused = true;
    }
    {
      match._props = {
        app-id = "^zen(-beta)?$";
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
