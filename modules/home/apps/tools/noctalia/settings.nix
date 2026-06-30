{ lib }:
let
  colors = lib.custom.colors;
in
{
  # Shell
  shell = {
    ui_scale = 1.0;
    font_family = "Iosevka";
    time_format = "{:%H:%M}";
    date_format = "%A, %x";
    clipboard_enabled = true;
    clipboard_history_max_entries = 100;
    polkit_agent = true;
  };

  # Wallpaper — disabled, swaybg handles it via niri spawn-at-startup
  wallpaper = {
    enabled = false;
  };

  # Theme — custom palette defined via programs.noctalia.customPalettes
  theme = {
    mode = "dark";
    source = "custom";
    custom_palette = "helios-catppuccin";
  };

  # Notifications
  notification = {
    enable_daemon = true;
    show_app_name = true;
    show_actions = true;
    layer = "top";
    background_opacity = 0.97;
    offset_x = 20;
    offset_y = 8;
  };

  # OSD
  osd = {
    position = "top_right";
    orientation = "horizontal";
    background_opacity = 0.97;
    offset_x = 20;
    offset_y = 8;
  };

  # Lock screen
  lockscreen = {
    enabled = true;
    blurred_desktop = false;
    blur_intensity = 0.5;
    tint_intensity = 0.3;
  };

  # System monitoring
  system.monitor = {
    enabled = true;
    cpu_poll_seconds = 2.0;
    memory_poll_seconds = 2.0;
    network_poll_seconds = 3.0;
  };

  # Audio
  audio = {
    enable_overdrive = false;
  };

  # Main bar
  bar.main = {
    position = "top";
    thickness = 34;
    background_opacity = 0.3;
    radius = 12;
    margin_h = 180;
    margin_v = 10;
    padding = 14;
    widget_spacing = 6;
    scale = 1.0;
    shadow = true;
    auto_hide = false;
    reserve_space = true;
    capsule = true;
    capsule_fill = "${colors.surface0.hex}cc";
    capsule_foreground = "${colors.text.hex}";
    capsule_radius = 8.0;
    border = "${colors.surface2.hex}";
    color = "${colors.text.hex}";
    icon_color = "${colors.subtext0.hex}";

    start = [
      "workspaces"
    ];
    center = [
      "clock"
    ];
    end = [
      "media"
      "tray"
      "network"
      "volume"
      "battery"
      "control-center"
      "session"
    ];
  };
}
