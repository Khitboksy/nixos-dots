# Testing profile - comprehensive stats for debugging
{
  lib,
  zenith,
  ...
}:

with zenith.lib';

''

  font_size=18
  font_face=Iosevka
  transparent_background
  frame_timing=0
  text_color=${colors.helios.text.hex'}

  fps_text=FPS
  fps_color_change
  fps_value=30,120,165
  fps_color=${colors.helios.red.hex'},${colors.helios.yellow.hex'},${colors.helios.sapphire.hex'}
  engine_color=${colors.helios.pink.hex'}
  frametime_color=${colors.helios.green.hex'}

  cpu_text=R7 5800x
  cpu_load_change
  cpu_load_value=30,60,90
  cpu_load_color=${colors.helios.sapphire.hex'},${colors.helios.yellow.hex'},${colors.helios.red.hex'}
  cpu_color=${colors.helios.pink.hex'}
  ram_color=${colors.helios.pink.hex'}

  gpu_text=RTX 2080
  gpu_load_change
  gpu_load_value=30,60,90
  gpu_load_color=${colors.helios.sapphire.hex'},${colors.helios.yellow.hex'},${colors.helios.red.hex'}
  gpu_color=${colors.helios.pink.hex'}
  vram_color=${colors.helios.pink.hex'}

  winesync
  wine_color=${colors.helios.pink.hex'}

  fps
  frametime
  frame_timing

  cpu_stats
  cpu_temp
  cpu_mhz
  ram

  gpu_stats
  gpu_temp
  gpu_core_clock
  vram

''
