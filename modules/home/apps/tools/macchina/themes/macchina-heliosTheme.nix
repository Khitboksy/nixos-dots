{ zenith }:

with zenith.lib'.colors;

{
  Helios = {

    hide_ascii = false;

    spacing = 2;
    padding = 4;

    separator_color = "${helios.green.hex}";
    separator = ">";

    key_color = "${helios.mauve.hex}";

    custom_ascii = {
      path = "~/.config/macchina/ascii/nixos_trans";
    };

  };
}
