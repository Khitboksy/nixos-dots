{ lib }:

with lib;
with lib.custom;

{
  # Workspaces
  workspace = [
    { _args = [ "games" ]; }
    { _args = [ "chat" ]; }
    { _args = [ "code" ]; }
    { _args = [ "browser" ]; }
  ];

  layout = {
    gaps = 8;
    background-color = "${colors.mantle.hex}";
    center-focused-column = "never";
    preset-column-widths._children = [
      { proportion = 0.33333; }
      { proportion = 0.5; }
      { proportion = 0.66667; }
    ];
    focus-ring = {
      on = [ ];
      active-color = "${colors.mauve.hex}";
      inactive-color = "${colors.sapphire.hex}";
      width = 6;
    };
    border = {
      on = [ ];
      active-color = "${colors.surface0.hex}";
      inactive-color = "${colors.sapphire.hex}";
      width = 2;
    };
  };

  # Animations
  animations = {
    on = [ ];

    workspace-switch = {
      spring._props = {
        damping-ratio = 0.85;
        stiffness = 700;
        epsilon = 0.0001;
      };
    };

    horizontal-view-movement = {
      spring._props = {
        damping-ratio = 0.85;
        stiffness = 700;
        epsilon = 0.0001;
      };
    };

    window-open = {
      custom-shader = builtins.readFile ../shaders/tileDrop_open.glsl;
    };

    window-close = {
      custom-shader = builtins.readFile ../shaders/tileDrop_close.glsl;
    };
  };

  # Blur effect
  blur = {
    passes = 3;
    offset = 6;
    noise = 0.02;
    saturation = 0.8;
  };
}
