{
  # Keyboard input
  input = [
    {
      keyboard.xkb = {
        layout = "en/us";
      };
    }
  ];

  # Output displays
  output = [
    {
      _args = [ "DP-1" ];
      mode = "1920x1080@165";
      position._props = {
        x = 0;
        y = 0;
      };
    }
    {
      _args = [ "HDMI-A-1" ];
      mode = "1366x768@60";
      position._props = {
        x = 0;
        y = 0;
      };
    }
  ];

  # Environment
  environment = {
    DISPLAY = ":0";
  };

  # Hotkey overlay
  hotkey-overlay = {
    skip-at-startup = true;
  };

  # Gestures - disabled
  gestures = {
    hot-corners = [ ];
  };

  # Spawn at startup
  spawn-at-startup = [
    [ "vesktop" ]
    [ "kitty" ]
    [ "zen" ]
  ];

  # Other settings
  prefer-no-csd = true;

  # Screenshot path
  screenshot-path = "/mnt/nix-data/media/screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
}
