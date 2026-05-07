{ lib }:

with lib;
with lib.custom;

{
  Helios = {

    hide_ascii = false;

    spacing = 2;
    padding = 4;

    separator_color = "${colors.green.hex}";
    separator = ">";

    key_color = "${colors.mauve.hex}";

    custom_ascii = {
      path = "~/.config/macchina/ascii/nixos_trans";
    };

  };
}