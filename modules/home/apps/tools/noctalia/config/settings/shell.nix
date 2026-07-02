{
  shell = {
    app_icon_colorize = false;
    avatar_path = "";
    clipboard_auto_paste = "auto";
    clipboard_confirm_clear_history = true;
    clipboard_enabled = true;
    clipboard_history_max_entries = 100;
    clipboard_image_action_command = "";
    corner_radius_scale = 1.0;
    date_format = "%A, %x";
    disable_mipmaps = false;
    font_family = "Iosevka";
    launch_apps_as_systemd_services = false;
    launch_apps_custom_command = "";
    middle_click_opens_widget_settings = true;
    niri_overview_type_to_launch_enabled = false;
    offline_mode = false;
    password_style = "default";
    polkit_agent = true;
    screen_time_enabled = false;
    settings_show_advanced = true;
    setup_wizard_enabled = true;
    shared_gl_context = true;
    show_location = true;
    telemetry_enabled = true;
    time_format = "{:%H:%M}";
    ui_scale = 1.0;

    animation = {
      enabled = true;
      speed = 1.0;
    };

    greeter_sync = {
      auto_sync = false;
    };

    launcher = {
      app_grid = false;
      categories = true;
      compact = false;
      session_search = false;
      show_icons = true;
      sort_by_usage = true;

      dmenu = { };
    };

    mpris = {
      blacklist = [ ];
    };

    panel = {
      borders = true;
      clipboard_placement = "floating";
      clipboard_position = "bottom_center";
      control_center_placement = "floating";
      control_center_position = "bottom_center";
      floating_offset = 8;
      launcher_placement = "floating";
      launcher_position = "center";
      open_near_click_clipboard = false;
      open_near_click_control_center = false;
      open_near_click_launcher = false;
      open_near_click_session = false;
      open_near_click_wallpaper = false;
      polkit_placement = "floating";
      polkit_position = "center";
      session_placement = "floating";
      session_position = "bottom_center";
      shadow = true;
      transparency_mode = "solid";
      wallpaper_placement = "attached";
      wallpaper_position = "auto";
    };

    privacy = {
      cam_filter_regex = "";
      mic_filter_regex = "";
    };

    screen_corners = {
      enabled = false;
      size = 8;
    };

    screenshot = {
      confirm_region = false;
      copy_to_clipboard = true;
      directory = "";
      filename_pattern = "";
      freeze_screen = true;
      pipe_command = "";
      pipe_to_command = false;
      save_to_file = true;
    };

    session = {
      power = { };

      actions = [
        {
          action = "lock";
          command = "";
          countdown_seconds = 0.0;
          enabled = true;
          glyph = "";
          label = "";
          shortcut = "1";
          variant = "primary";
        }
        {
          action = "logout";
          command = "";
          countdown_seconds = 0.0;
          enabled = true;
          glyph = "";
          label = "";
          shortcut = "2";
          variant = "outline";
        }
        {
          action = "lock_and_suspend";
          command = "";
          countdown_seconds = 0.0;
          enabled = true;
          glyph = "";
          label = "";
          shortcut = "3";
          variant = "outline";
        }
        {
          action = "reboot";
          command = "";
          countdown_seconds = 5.0;
          enabled = true;
          glyph = "";
          label = "";
          shortcut = "4";
          variant = "outline";
        }
        {
          action = "shutdown";
          command = "";
          countdown_seconds = 5.0;
          enabled = true;
          glyph = "";
          label = "";
          shortcut = "5";
          variant = "destructive";
        }
      ];
    };

    shadow = {
      alpha = 0.55;
      direction = "down";
    };
  };
}
