{ lib }:
let
  # Convert a single hex char to int
  hexCharToInt =
    char:
    let
      charCode = lib.strings.charToInt char;
      zeroCode = lib.strings.charToInt "0";
      nineCode = lib.strings.charToInt "9";
      aCode = lib.strings.charToInt "a";
      fCode = lib.strings.charToInt "f";
      ACode = lib.strings.charToInt "A";
      FCode = lib.strings.charToInt "F";
    in
    if charCode >= zeroCode && charCode <= nineCode then
      charCode - zeroCode
    else if charCode >= aCode && charCode <= fCode then
      charCode - aCode + 10
    else if charCode >= ACode && charCode <= FCode then
      charCode - ACode + 10
    else
      builtins.throw "Invalid hex character: ${builtins.toString char}";

  # Convert a hex component (e.g., "ff") to int
  hexCompToInt =
    hexComp:
    let
      trimmedStr = lib.strings.removePrefix "0x" hexComp;
      chars = lib.strings.stringToCharacters trimmedStr;
      op = acc: char: (acc * 16) + (hexCharToInt char);
    in
    if trimmedStr == "" then 0 else builtins.foldl' op 0 chars;

  # Convert int to 2-digit hex
  intCompToHex =
    intComp:
    let
      clampedInt = lib.max 0 (lib.min 255 (builtins.floor (intComp + 0.5)));
      hexString = lib.trivial.toHexString clampedInt;
    in
    lib.strings.fixedWidthString 2 "0" hexString;

  # Hex to RGB record
  hexToRgb =
    hexColor:
    let
      hex = lib.strings.removePrefix "#" hexColor;
    in
    {
      r = hexCompToInt (lib.strings.substring 0 2 hex);
      g = hexCompToInt (lib.strings.substring 2 2 hex);
      b = hexCompToInt (lib.strings.substring 4 2 hex);
    };

  # RGB to Hex
  rgbToHex =
    rgbColor: "#${intCompToHex rgbColor.r}${intCompToHex rgbColor.g}${intCompToHex rgbColor.b}";

  # RGB to HSL string
  rgbToHsl =
    rgb:
    let
      r = rgb.r / 255;
      g = rgb.g / 255;
      b = rgb.b / 255;

      maxVal = builtins.foldl' builtins.max 0 [
        r
        g
        b
      ];
      minVal = builtins.foldl' builtins.min 1 [
        r
        g
        b
      ];
      l = (maxVal + minVal) / 2;

      # Calculate saturation
      s =
        if maxVal == minVal then
          0
        else if l < 0.5 then
          (maxVal - minVal) / (maxVal + minVal)
        else
          (maxVal - minVal) / (2 - maxVal - minVal);

      # Calculate hue
      h =
        if maxVal == minVal then
          0
        else if maxVal == r then
          let
            diff = (g - b) / (maxVal - minVal);
          in
          if diff < 0 then diff + 6 else diff
        else if maxVal == g then
          ((b - r) / (maxVal - minVal)) + 2
        else
          ((r - g) / (maxVal - minVal)) + 4;

      hDeg = builtins.floor (h * 60);
      sPct = builtins.floor (s * 100);
      lPct = builtins.floor (l * 100);
    in
    "hsl(${toString hDeg}, ${toString sPct}%, ${toString lPct}%)";

  # Hex to HSL string
  hexToHsl = hex: rgbToHsl (hexToRgb hex);

  # Linearly interpolate between two hex colors
  lerpColorFunc =
    color1Hex: color2Hex: t:
    let
      rgb1 = hexToRgb color1Hex;
      rgb2 = hexToRgb color2Hex;
      lerpedR = (rgb1.r * (1.0 - t)) + (rgb2.r * t);
      lerpedG = (rgb1.g * (1.0 - t)) + (rgb2.g * t);
      lerpedB = (rgb1.b * (1.0 - t)) + (rgb2.b * t);
    in
    rgbToHex {
      r = lerpedR;
      g = lerpedG;
      b = lerpedB;
    };

  in
{
  colors = rec {
    bg = crust;
    fg = text;
    primary = pink;

    rosewater = { hex = "#f5e0dc"; };
    flamingo = { hex = "#f2cdcd"; };
    pink = { hex = "#f5c2e7"; };
    mauve = { hex = "#cba6f7"; };
    red = { hex = "#f38ba8"; };
    maroon = { hex = "#eba0ac"; };
    peach = { hex = "#fab387"; };
    yellow = { hex = "#f9e2af"; };
    green = { hex = "#a6e3a1"; };
    teal = { hex = "#94e2d5"; };
    sky = { hex = "#89dceb"; };
    sapphire = { hex = "#74c7ec"; };
    blue = { hex = "#89b4fa"; };
    lavender = { hex = "#b4befe"; };
    text = { hex = "#cdd6f4"; };
    subtext1 = { hex = "#bac2de"; };
    subtext0 = { hex = "#a6adc8"; };
    overlay2 = { hex = "#9399b2"; };
    overlay1 = { hex = "#7f849c"; };
    overlay0 = { hex = "#6c7086"; };
    surface2 = { hex = "#585b70"; };
    surface1 = { hex = "#45475a"; };
    surface0 = { hex = "#313244"; };
    base = { hex = "#1e1e2e"; };
    mantle = { hex = "#181825"; };
    crust = { hex = "#11111b"; };
  };

  wallpaper = ./wall4.jpg;
  inherit hexToRgb;
  inherit hexToHsl;
  lerpColor = lerpColorFunc;
}

