{
  auto_hide = false;
  background_opacity = 0.3;
  border = "outline";
  border_width = 0.0;
  capsule = false;
  capsule_fill = "surface_variant";
  capsule_opacity = 1.0;
  capsule_padding = 6.0;
  capsule_thickness = 0.75;
  center = [ "workspaces" ];
  contact_shadow = false;
  enabled = true;
  end = [ "group:g2" ];
  font_weight = 600;
  layer = "top";
  margin_edge = 0;
  margin_ends = 180;
  margin_opposite_edge = 0;
  padding = 8;
  panel_overlap = -1;
  position = "left";
  radius = 6;
  radius_bottom_left = 0;
  radius_bottom_right = 6;
  radius_top_left = 0;
  radius_top_right = 6;
  reserve_space = false;
  scale = 1.0;
  shadow = false;
  show_on_workspace_switch = true;
  start = [ "group:g1" ];
  thickness = 34;
  widget_spacing = 4;

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
      radius = 6.0;
    }
    {
      border = "tertiary";
      fill = "surface_variant";
      foreground = "primary";
      id = "g2";
      members = [
        "volume"
        "battery"
        "power_profile"
      ];
      opacity = 0.75;
      padding = 6.0;
      radius = 6.0;
    }
  ];
}
