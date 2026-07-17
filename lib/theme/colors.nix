{
  hexToRgb,
  hexToHsl,
  hexToAnsi,
  stripHash,
  ...
}:
{
  # Catpuccin-Mocha Colour
  rosewater =
    let
      hex = "#f5e0dc";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  flamingo =
    let
      hex = "#f2cdcd";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  pink =
    let
      hex = "#f5c2e7";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  mauve =
    let
      hex = "#cba6f7";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  red =
    let
      hex = "#f38ba8";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  maroon =
    let
      hex = "#eba0ac";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  peach =
    let
      hex = "#fab387";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  yellow =
    let
      hex = "#f9e2af";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  green =
    let
      hex = "#a6e3a1";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  teal =
    let
      hex = "#94e2d5";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  sky =
    let
      hex = "#89dceb";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  sapphire =
    let
      hex = "#74c7ec";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  blue =
    let
      hex = "#89b4fa";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  lavender =
    let
      hex = "#b4befe";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };

  # Catpuccin Greyscale
  text =
    let
      hex = "#cdd6f4";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  subtext1 =
    let
      hex = "#bac2de";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  subtext0 =
    let
      hex = "#a6adc8";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  overlay2 =
    let
      hex = "#9399b2";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  overlay1 =
    let
      hex = "#7f849c";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  overlay0 =
    let
      hex = "#6c7086";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  surface2 =
    let
      hex = "#585b70";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  surface1 =
    let
      hex = "#45475a";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  surface0 =
    let
      hex = "#313244";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  base =
    let
      hex = "#1e1e2e";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  mantle =
    let
      hex = "#181825";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  crust =
    let
      hex = "#11111b";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };

  # SHES TRANS???
  tblue =
    let
      hex = "#5BCEFA";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  tpink =
    let
      hex = "#F5A9B8";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };

  # Saturated
  white =
    let
      hex = "#ffffff";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  black =
    let
      hex = "#000000";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  rgb-blue =
    let
      hex = "#0000ff";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  rgb-red =
    let
      hex = "#ff0000";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
  rgb-green =
    let
      hex = "#00ff00";
    in
    {
      inherit hex;
      hex' = stripHash hex;
      rgb = hexToRgb hex;
      hsl = hexToHsl hex;
      ansi = hexToAnsi hex;
    };
}
