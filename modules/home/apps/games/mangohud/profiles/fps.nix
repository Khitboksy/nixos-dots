# FPS-only minimal profile
{
  lib,
  ...
}:

with lib;
with lib.custom;

''

  font_size=18
  font_face=Iosevka
  transparent_background
  text_color=${colors.helios.text.hex'}

  fps_text=FPS
  fps_color_change
  fps_value=30,120,165
  fps_color=${colors.helios.red.hex'},${colors.helios.yellow.hex'},${colors.helios.sapphire.hex'}
  engine_color=${colors.helios.pink.hex'}

  fps_only

''
