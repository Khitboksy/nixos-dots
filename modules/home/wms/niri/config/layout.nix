{
  # Workspaces
  workspace = [
    { _args = [ "games" ]; }
    { _args = [ "chat" ]; }
    { _args = [ "code" ]; }
    { _args = [ "browser" ]; }
    { _args = [ "misc" ]; }
  ];

  # Layout config (colors set in default.nix)
  layout = {
    geometry-corner-radius = [
      12
      12
      12
      12
    ];
    clip-to-geometry = true;
    opacity = 0.8;
    background-effect = {
      blur = true;
    };
    draw-border-with-background = false;

    gaps = 8;
    center-focused-column = "never";
    preset-column-widths._children = [
      { proportion = 0.33333; }
      { proportion = 0.5; }
      { proportion = 0.66667; }
    ];
    focus-ring = {
      on = [ ];
      width = 4;
    };
    border = {
      on = [ ];
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
