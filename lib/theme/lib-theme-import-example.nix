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
  color0 = "${colors.surface1.hex}";
  color8 = "${colors.surface2.hex}";
  color1 = "${colors.red.hex}";
  color9 = "${colors.red.hex}";
  color2 = "${colors.green.hex}";
  color10 = "${colors.green.hex}";
  color3 = "${colors.yellow.hex}";
  color11 = "${colors.yellow.hex}";
  color4 = "${colors.blue.hex}";
  color12 = "${colors.blue.hex}";
  color5 = "${colors.pink.hex}";
  color13 = "${colors.pink.hex}";
  color6 = "${colors.teal.hex}";
  color14 = "${colors.teal.hex}";
  color7 = "${colors.subtext1.hex}";
  color15 = "${colors.subtext0.hex}";
}
