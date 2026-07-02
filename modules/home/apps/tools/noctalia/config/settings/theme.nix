{
  theme = {
    builtin = "Catppuccin";
    community_palette = "Oxocarbon";
    custom_palette = "helios-catppuccin";
    mode = "dark";
    source = "custom";
    wallpaper_scheme = "m3-content";

    templates = {
      builtin_ids = [ ];
      community_ids = [ ];
      enable_builtin_templates = true;
      enable_community_templates = true;
    };
  };

  wallpaper = {
    directory = "";
    directory_dark = "";
    directory_light = "";
    edge_smoothness = 0.3;
    enabled = false;
    fill_color = "";
    fill_mode = "crop";
    per_monitor_directories = false;
    transition = [
      "fade"
      "wipe"
      "disc"
      "stripes"
      "zoom"
      "honeycomb"
    ];
    transition_duration = 1500.0;
    transition_on_startup = false;

    automation = {
      enabled = false;
      interval_seconds = 1800;
      order = "random";
      recursive = true;
    };
  };

  nightlight = {
    enabled = false;
    force = false;
    temperature_day = 6500;
    temperature_night = 4000;
  };

  weather = {
    effects = false;
    enabled = true;
    refresh_minutes = 30;
    unit = "metric";
  };
}
