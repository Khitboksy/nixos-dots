{ lib, zenith }:
with zenith.lib';
''
  local M = {
  rosewater = "${colors.helios.rosewater.hex}",
  flamingo = "${colors.helios.flamingo.hex}",
  pink = "${colors.helios.pink.hex}",
  mauve = "${colors.helios.mauve.hex}",
  red = "${colors.helios.red.hex}",
  maroon = "${colors.helios.maroon.hex}",
  peach = "${colors.helios.peach.hex}",
  yellow = "${colors.helios.yellow.hex}",
  green = "${colors.helios.green.hex}",
  teal = "${colors.helios.teal.hex}",
  sky = "${colors.helios.sky.hex}",
  sapphire = "${colors.helios.sapphire.hex}",
  blue = "${colors.helios.blue.hex}",
  lavender = "${colors.helios.lavender.hex}",
  text = "${colors.helios.text.hex}",
  subtext1 = "${colors.helios.subtext1.hex}",
  subtext0 = "${colors.helios.subtext0.hex}",
  overlay2 = "${colors.helios.overlay2.hex}",
  overlay1 = "${colors.helios.overlay1.hex}",
  overlay0 = "${colors.helios.overlay0.hex}",
  surface2 = "${colors.helios.surface2.hex}",
  surface1 = "${colors.helios.surface1.hex}",
  surface0 = "${colors.helios.surface0.hex}",
  base = "${colors.helios.base.hex}",
  mantle = "${colors.helios.mantle.hex}",
  crust = "${colors.helios.crust.hex}",
  }
  return M
''
