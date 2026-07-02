{
  auto_hide = true;
  background_opacity = 0.3;
  border = "primary";
  border_width = 2.5;
  capsule = false;
  capsule_fill = "surface_variant";
  capsule_opacity = 1.0;
  capsule_padding = 6.0;
  capsule_thickness = 0.76;
  center = [ "workspaces" ];
  contact_shadow = false;
  enabled = true;
  end = [
    "group:g3"
    "group:g2"
  ];
  font_weight = 700;
  layer = "top";
  margin_edge = 4;
  margin_ends = 120;
  margin_opposite_edge = 0;
  padding = 8;
  panel_overlap = 1;
  position = "right";
  radius = 8;
  radius_bottom_left = 8;
  radius_bottom_right = 8;
  radius_top_left = 8;
  radius_top_right = 8;
  reserve_space = false;
  scale = 1.0;
  shadow = false;
  show_on_workspace_switch = false;
  start = [ "group:g1" ];
  thickness = 34;
  widget_spacing = 6;

  dead_zone = {
    command = "";
    middle_command = "";
    right_command = "";
    scroll_down_command = "";
    scroll_up_command = "";
  };

  capsule_group = [
    {
      border = "tertiary";
      fill = "surface_variant";
      foreground = "primary";
      id = "g1";
      members = [
        "clock"
        "weather"
      ];
      opacity = 0.75;
      padding = 6.0;
      radius = 8.0;
    }
    {
      border = "tertiary";
      fill = "surface_variant";
      foreground = "primary";
      id = "g2";
      members = [
        "volume"
        "bluetooth"
      ];
      opacity = 0.75;
      padding = 6.0;
      radius = 6.0;
    }
    {
      border = "tertiary";
      fill = "surface_variant";
      foreground = "primary";
      id = "g3";
      members = [
        "cpu"
        "ram"
      ];
      opacity = 0.75;
      padding = 6.0;
      radius = 6.0;
    }
  ];
}
