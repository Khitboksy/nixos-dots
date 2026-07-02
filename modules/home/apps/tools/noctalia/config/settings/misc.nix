{
  backdrop = {
    blur_intensity = 0.0;
    enabled = false;
    tint_intensity = 0.0;
  };

  calendar = {
    enabled = false;
    refresh_minutes = 15;
  };

  dock = {
    active_monitor_only = false;
    active_opacity = 1.0;
    active_scale = 1.0;
    auto_hide = false;
    background_opacity = 0.88;
    cross_axis_padding = 8;
    enabled = false;
    icon_size = 48;
    inactive_opacity = 0.85;
    inactive_scale = 0.85;
    item_spacing = 6;
    launcher_icon = "grid-dots";
    launcher_position = "none";
    magnification = true;
    magnification_scale = 1.45;
    main_axis_padding = 16;
    margin_edge = 8;
    margin_ends = 0;
    monitors = [ ];
    pinned = [ ];
    position = "bottom";
    radius = 16;
    radius_bottom_left = 16;
    radius_bottom_right = 16;
    radius_top_left = 16;
    radius_top_right = 16;
    reserve_space = true;
    shadow = true;
    show_dots = false;
    show_instance_count = true;
    show_running = true;
  };

  hooks = {
    battery_charging = [ ];
    battery_discharging = [ ];
    battery_percentage_changed = [ ];
    battery_plugged = [ ];
    bluetooth_disabled = [ ];
    bluetooth_enabled = [ ];
    colors_changed = [ ];
    logging_out = [ ];
    power_profile_changed = [ ];
    rebooting = [ ];
    session_locked = [ ];
    session_unlocked = [ ];
    shutting_down = [ ];
    started = [ ];
    theme_mode_changed = [ ];
    wallpaper_changed = [ ];
    wifi_disabled = [ ];
    wifi_enabled = [ ];
  };

  idle = {
    behavior_order = [
      "lock"
      "screen-off"
      "lock-and-suspend"
    ];
    pre_action_fade_seconds = 2.0;

    behavior = {
      lock = {
        action = "lock";
        command = "";
        enabled = false;
        resume_command = "";
        timeout = 600.0;
      };
      lock-and-suspend = {
        action = "lock_and_suspend";
        command = "";
        enabled = false;
        resume_command = "";
        timeout = 900.0;
      };
      screen-off = {
        action = "screen_off";
        command = "";
        enabled = false;
        resume_command = "";
        timeout = 660.0;
      };
    };
  };

  keybinds = {
    cancel = [ "Escape" ];
    down = [ "Down" ];
    left = [ "Left" ];
    right = [ "Right" ];
    tab_next = [ "Tab" ];
    tab_previous = [ "Shift+ISO_Left_Tab" ];
    up = [ "Up" ];
    validate = [
      "Return"
      "KP_Enter"
      "space"
    ];
  };

  location = {
    address = "Alvin, United States";
    auto_locate = false;
    sunrise = "";
    sunset = "";
  };

  plugins = {
    enabled = [ ];

    source = [
      {
        auto_update = false;
        enabled = true;
        kind = "git";
        location = "https://github.com/noctalia-dev/official-plugins";
        name = "official";
      }
      {
        auto_update = false;
        enabled = true;
        kind = "git";
        location = "https://github.com/noctalia-dev/community-plugins";
        name = "community";
      }
    ];
  };
}
