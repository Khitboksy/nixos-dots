# FPS-only minimal profile
{
  lib,
  stripHash,
  ...
}:

with lib;
with lib.custom;

''

  font_size=18
  font_face=Iosevka
  transparent_background
  text_color=${stripHash colors.text.hex}

  fps_text=FPS
  fps_color_change
  fps_value=30,120,165
  fps_color=${stripHash colors.red.hex},${stripHash colors.yellow.hex},${stripHash colors.sapphire.hex}
  engine_color=${stripHash colors.pink.hex}

  fps_only

''
