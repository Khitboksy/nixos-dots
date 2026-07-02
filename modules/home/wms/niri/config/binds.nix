{

  binds = {
    "Mod+Return" = {
      spawn = "kitty-launcher";
    };
    "Mod+D" = {
      spawn = [
        "fish"
        "-c"
        "rofi -show drun"
      ];
    };
    "Mod+Z" = {
      spawn = "zen";
    };
    "Mod+Q" = {
      close-window = [ ];
    };
    "Mod+H" = {
      focus-column-left = [ ];
    };
    "Mod+J" = {
      focus-workspace-down = [ ];
    };
    "Mod+K" = {
      focus-workspace-up = [ ];
    };
    "Mod+L" = {
      focus-column-right = [ ];
    };
    "Mod+Home" = {
      focus-column-first = [ ];
    };
    "Mod+End" = {
      focus-column-last = [ ];
    };
    "Mod+Shift+J" = {
      focus-workspace-down = [ ];
    };
    "Mod+Shift+K" = {
      focus-workspace-up = [ ];
    };
    "Mod+Page_Down" = {
      focus-workspace-down = [ ];
    };
    "Mod+Page_Up" = {
      focus-workspace-up = [ ];
    };
    "Mod+U" = {
      focus-workspace-down = [ ];
    };
    "Mod+I" = {
      focus-workspace-up = [ ];
    };
    "Mod+WheelScrollDown" = {
      _props = {
        cooldown-ms = 150;
      };
      focus-workspace-down = [ ];
    };
    "Mod+WheelScrollUp" = {
      _props = {
        cooldown-ms = 150;
      };
      focus-workspace-up = [ ];
    };
    "Mod+Ctrl+Shift+F" = {
      toggle-windowed-fullscreen = [ ];
    };
    "Mod+Ctrl+H" = {
      move-column-left = [ ];
    };
    "Mod+Ctrl+J" = {
      focus-workspace-down = [ ];
    };
    "Mod+Ctrl+K" = {
      focus-workspace-up = [ ];
    };
    "Mod+Ctrl+L" = {
      move-column-right = [ ];
    };
    "Mod+Shift+Page_Down" = {
      move-workspace-down = [ ];
    };
    "Mod+Shift+Page_Up" = {
      move-workspace-up = [ ];
    };
    "Mod+Shift+U" = {
      move-workspace-down = [ ];
    };
    "Mod+Shift+I" = {
      move-workspace-up = [ ];
    };
    "Mod+Ctrl+Page_Down" = {
      move-column-to-workspace-down = [ ];
    };
    "Mod+Ctrl+Page_Up" = {
      move-column-to-workspace-up = [ ];
    };
    "Mod+R" = {
      switch-preset-column-width = [ ];
    };
    "Mod+Shift+R" = {
      switch-preset-window-height = [ ];
    };
    "Mod+F" = {
      maximize-column = [ ];
    };
    "Mod+Shift+F" = {
      fullscreen-window = [ ];
    };
    "Mod+C" = {
      center-column = [ ];
    };
    "Mod+Shift+V" = {
      toggle-window-floating = [ ];
    };
    "Mod+Shift+Comma" = {
      consume-window-into-column = [ ];
    };
    "Mod+Period" = {
      expel-window-from-column = [ ];
    };
    "Mod+Minus" = {
      set-column-width = "-10%";
    };
    "Mod+Equal" = {
      set-column-width = "+10%";
    };
    "Mod+Shift+Minus" = {
      set-window-height = "-10%";
    };
    "Mod+Shift+Equal" = {
      set-window-height = "+10%";
    };
    "Print" = {
      screenshot = [ ];
    };
    "Mod+Shift+E" = {
      quit = [ ];
    };
    "Mod+Shift+L" = {
      spawn = "swaylock --grace 0";
    };
    "Mod+Shift+Slash" = {
      show-hotkey-overlay = [ ];
    };
    "Mod+1" = {
      focus-workspace = 1;
    };
    "Mod+2" = {
      focus-workspace = 2;
    };
    "Mod+3" = {
      focus-workspace = 3;
    };
    "Mod+4" = {
      focus-workspace = 4;
    };
    "Mod+5" = {
      focus-workspace = 5;
    };
    "Mod+6" = {
      focus-workspace = 6;
    };
    "Mod+7" = {
      focus-workspace = 7;
    };
    "Mod+8" = {
      focus-workspace = 8;
    };
    "Mod+9" = {
      focus-workspace = 9;
    };
    "Mod+Shift+1" = {
      move-window-to-workspace = 1;
    };
    "Mod+Shift+2" = {
      move-window-to-workspace = 2;
    };
    "Mod+Shift+3" = {
      move-window-to-workspace = 3;
    };
    "Mod+Shift+4" = {
      move-window-to-workspace = 4;
    };
    "Mod+Shift+5" = {
      move-window-to-workspace = 5;
    };
    "Mod+Shift+6" = {
      move-window-to-workspace = 6;
    };
    "Mod+Shift+7" = {
      move-window-to-workspace = 7;
    };
    "Mod+Shift+8" = {
      move-window-to-workspace = 8;
    };
    "Mod+Shift+9" = {
      move-window-to-workspace = 9;
    };
    "Mod+Left" = {
      focus-column-left = [ ];
    };
    "Mod+Down" = {
      focus-workspace-down = [ ];
    };
    "Mod+Up" = {
      focus-workspace-up = [ ];
    };
    "Mod+Right" = {
      focus-column-right = [ ];
    };
    "Mod+Ctrl+Left" = {
      move-column-left = [ ];
    };
    "Mod+Ctrl+Down" = {
      move-column-to-workspace-down = [ ];
    };
    "Mod+Ctrl+Up" = {
      move-column-to-workspace-up = [ ];
    };
    "Mod+Ctrl+Right" = {
      move-column-right = [ ];
    };
    "Mod+Ctrl+Home" = {
      move-column-to-first = [ ];
    };
    "Mod+Ctrl+End" = {
      move-column-to-last = [ ];
    };
    "Mod+Shift+WheelScrollDown" = {
      focus-column-right = [ ];
    };
    "Mod+Shift+WheelScrollUp" = {
      focus-column-left = [ ];
    };
    "Mod+Ctrl+WheelScrollDown" = {
      move-column-to-workspace-down = [ ];
    };
    "Mod+Ctrl+WheelScrollUp" = {
      move-column-to-workspace-up = [ ];
    };
    "Mod+Ctrl+WheelScrollRight" = {
      move-column-right = [ ];
    };
    "Mod+Ctrl+WheelScrollLeft" = {
      move-column-left = [ ];
    };
    "Mod+Ctrl+Shift+WheelScrollDown" = {
      move-column-right = [ ];
    };
    "Mod+Ctrl+Shift+WheelScrollUp" = {
      move-column-left = [ ];
    };
    "Mod+BracketLeft" = {
      consume-or-expel-window-left = [ ];
    };
    "Mod+BracketRight" = {
      consume-or-expel-window-right = [ ];
    };
    "Mod+Ctrl+R" = {
      reset-window-height = [ ];
    };
    "Mod+Ctrl+F" = {
      expand-column-to-available-width = [ ];
    };
    "Ctrl+Alt+Delete" = {
      quit = [ ];
    };
    "Mod+Shift+End" = {
      power-off-monitors = [ ];
    };
  };
}
