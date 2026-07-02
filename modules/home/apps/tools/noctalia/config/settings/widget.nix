{
  widget = {
    active_window = {
      icon_size = 14.0;
      max_length = 260.0;
      min_length = 80.0;
      title_scroll = "none";
      type = "active_window";
    };

    audio_visualizer = {
      centered = false;
      color_2 = "tertiary";
      show_when_idle = true;
      type = "audio_visualizer";
    };

    cpu = {
      show_label = false;
      stat = "cpu_usage";
      type = "sysmon";
    };

    date = {
      format = "{:%a %d %b}";
      type = "clock";
    };

    input_volume = {
      device = "input";
      type = "volume";
    };

    keyboard_layout = {
      cycle_command = "";
      hide_when_single_layout = false;
      type = "keyboard_layout";
    };

    lock_keys = {
      display = "short";
      hide_when_off = false;
      show_caps_lock = true;
      show_num_lock = true;
      show_scroll_lock = false;
      type = "lock_keys";
    };

    media = {
      art_size = 16.0;
      hide_album_art = true;
      hide_when_no_media = true;
      max_length = 220.0;
      min_length = 80.0;
      title_scroll = "on_hover";
      type = "media";
    };

    network = {
      show_label = false;
      type = "network";
    };

    network_rx = {
      stat = "net_rx";
      type = "sysmon";
    };

    network_tx = {
      stat = "net_tx";
      type = "sysmon";
    };

    output_volume = {
      device = "output";
      type = "volume";
    };

    power_profile = {
      capsule = true;
      type = "power_profile";
    };

    ram = {
      show_label = false;
      stat = "ram_used";
      type = "sysmon";
    };

    spacer = {
      type = "spacer";
    };

    spacer_2 = {
      length = 245;
      type = "spacer";
    };

    temp = {
      stat = "cpu_temp";
      type = "sysmon";
    };

    volume = {
      show_label = false;
      type = "volume";
    };

    weather = {
      show_condition = false;
      type = "weather";
    };

    workspaces = {
      active_pill_size = 2.4;
      anchor = true;
      capsule = true;
      capsule_opacity = 0.75;
      capsule_radius = 4;
      display = "none";
      hide_when_empty = true;
      inactive_pill_size = 1.2;
      occupied_color = "tertiary";
      type = "workspaces";
    };
  };
}
