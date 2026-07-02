{
  audio = {
    enable_overdrive = false;
    enable_sounds = false;
    notification_sound = "";
    sound_volume = 0.5;
    volume_change_sound = "";
  };

  battery = {
    warning_threshold = 10;
  };

  brightness = {
    enable_ddcutil = false;
    ignore_mmids = [ ];
    minimum_brightness = 0.0;
    sync_all_monitors = false;
  };

  notification = {
    background_opacity = 0.97;
    collapse_on_dismiss = true;
    enable_daemon = true;
    layer = "overlay";
    monitors = [ ];
    offset_x = 20;
    offset_y = 8;
    position = "top_right";
    scale = 1.0;
    show_actions = true;
    show_app_name = true;
  };

  osd = {
    background_opacity = 0.97;
    monitors = [ ];
    offset_x = 20;
    offset_y = 8;
    orientation = "horizontal";
    position = "top_right";
    position_vertical = "top_center";
    scale = 1.0;

    kinds = {
      bluetooth = true;
      brightness = true;
      caffeine = true;
      dnd = true;
      keyboard_layout = true;
      lock_keys = true;
      media = true;
      nightlight = true;
      power_profile = true;
      privacy = true;
      volume = true;
      volume_input = true;
      volume_output = true;
      wifi = true;
    };
  };

  system = {
    monitor = {
      cpu_poll_seconds = 2.0;
      cpu_temp_activity_threshold = 60.0;
      cpu_temp_critical_threshold = 85.0;
      cpu_temp_sensor_path = "";
      cpu_usage_activity_threshold = 50.0;
      cpu_usage_critical_threshold = 90.0;
      disk_pct_activity_threshold = 80.0;
      disk_pct_critical_threshold = 95.0;
      disk_poll_seconds = 10.0;
      enabled = true;
      gpu_poll_seconds = 0.0;
      gpu_temp_activity_threshold = 60.0;
      gpu_temp_critical_threshold = 85.0;
      gpu_usage_activity_threshold = 50.0;
      gpu_usage_critical_threshold = 95.0;
      gpu_vram_activity_threshold = 50.0;
      gpu_vram_critical_threshold = 90.0;
      memory_poll_seconds = 2.0;
      net_rx_activity_threshold = 1.0;
      net_rx_critical_threshold = 50.0;
      net_tx_activity_threshold = 1.0;
      net_tx_critical_threshold = 50.0;
      network_poll_seconds = 3.0;
      ram_pct_activity_threshold = 60.0;
      ram_pct_critical_threshold = 90.0;
      swap_pct_activity_threshold = 20.0;
      swap_pct_critical_threshold = 80.0;
    };
  };
}
