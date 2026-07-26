# Notes for humans and agents alike.
#
# This example is purely documentation,
# and is not referenced anywhere in the configuration.

{
  lib, # `lib` gets passed from ./default.nix
  ...
}:
# Bring lib.custom helpers into scope (specifically we want the `colors.` helper)
with lib;
with lib.custom;
{
  color0 = "${colors.helios.surface1.hex}";
  color8 = "${colors.helios.surface2.hex}";
  color1 = "${colors.helios.red.hex}";
  color9 = "${colors.helios.red.hex}";
  color2 = "${colors.helios.green.hex}";
  color10 = "${colors.helios.green.hex}";
  color3 = "${colors.helios.yellow.hex}";
  color11 = "${colors.helios.yellow.hex}";
  color4 = "${colors.helios.blue.hex}";
  color12 = "${colors.helios.blue.hex}";
  color5 = "${colors.helios.pink.hex}";
  color13 = "${colors.helios.pink.hex}";
  color6 = "${colors.helios.teal.hex}";
  color14 = "${colors.helios.teal.hex}";
  color7 = "${colors.helios.subtext1.hex}";
  color15 = "${colors.helios.subtext0.hex}";
}
