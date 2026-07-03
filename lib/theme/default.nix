{ lib }:
let
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
      throw "Invalid hex character: ${toString char}";

  hexCompToInt =
    hexComp:
    let
      trimmedStr = lib.strings.removePrefix "0x" hexComp;
    in
    if trimmedStr == "" then
      0
    else
      trimmedStr
      |> lib.strings.stringToCharacters
      |> builtins.foldl' (acc: char: (acc * 16) + (hexCharToInt char)) 0;

  intCompToHex =
    intComp:
    let
      clampedInt =
        (lib.max 0)
        <| (lib.min 255)
        <| builtins.floor
        <| (intComp + 0.5);
      hexString = lib.trivial.toHexString clampedInt;
    in
    lib.strings.fixedWidthString 2 "0" hexString;

  hexToRgb =
    hexColor:
    let
      stripHash = lib.strings.removePrefix "#";
      getPart =
        start: len:
        hexCompToInt
        <| lib.strings.substring start len
        <| stripHash
        <| hexColor;
    in
    {
      r = getPart 0 2;
      g = getPart 2 2;
      b = getPart 4 2;
    };

  rgbToHex =
    rgbColor: "#${intCompToHex rgbColor.r}${intCompToHex rgbColor.g}${intCompToHex rgbColor.b}";

  rgbToHsl =
    rgb:
    let
      r = rgb.r / 255;
      g = rgb.g / 255;
      b = rgb.b / 255;

      maxVal = builtins.foldl' (a: b: if a > b then a else b) 0 [
        r
        g
        b
      ];
      minVal = builtins.foldl' (a: b: if a < b then a else b) 1 [
        r
        g
        b
      ];
      l = (maxVal + minVal) / 2;

      s =
        if maxVal == minVal then
          0
        else if l < 0.5 then
          (maxVal - minVal) / (maxVal + minVal)
        else
          (maxVal - minVal) / (2 - maxVal - minVal);

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

  hexToHsl = hex: rgbToHsl <| hexToRgb <| hex;

  lerpColor =
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

  hexToAnsi =
    hex:
    let
      c = hexToRgb hex;
    in
    "\\033[38;2;${toString c.r};${toString c.g};${toString c.b}m";

  ansiReset = "\\033[0m";

  # ── CSS generation helpers ──────────────────────────────────────────

  # Expand compact font-face variant tuples into full attrsets.
  #   variants: [ [ weight stretch style fileSuffix ] ... ]
  #   Optional: dirWoff2 and dirTtf override the base dir for each format.
  mkFontFaces =
    {
      family,
      display ? "swap",
      dir ? "",
      dirWoff2 ? null,
      dirTtf ? null,
      prefix,
      variants,
    }:
    map (
      v:
      {
        inherit family display dir;
        weight = builtins.elemAt v 0;
        stretch = builtins.elemAt v 1;
        style = builtins.elemAt v 2;
        file = "${prefix}-${builtins.elemAt v 3}";
      }
      // (if dirWoff2 != null then { dirWoff2 = "${dirWoff2}"; } else { })
      // (if dirTtf != null then { dirTtf = "${dirTtf}"; } else { })
    ) variants;

  # Render a single @font-face block to CSS text.
  # Supports separate directories for woff2 and ttf via dirWoff2/dirTtf
  # (falls back to `dir` for either, then to "").
  renderFontFace =
    f:
    let
      d = f.dir or "";
      woff2Dir =
        if f ? dirWoff2 then
          f.dirWoff2
        else if f ? dir then
          "${f.dir}WOFF2/"
        else
          "";
      ttfDir =
        if f ? dirTtf then
          f.dirTtf
        else if f ? dir then
          "${f.dir}TTF/"
        else
          "";
    in
    ''
      @font-face {
      	font-family: '${f.family}';
      	font-display: ${f.display or "swap"};
      	font-weight: ${toString f.weight};
      	font-stretch: ${f.stretch};
      	font-style: ${f.style};
      	src: url('${woff2Dir}${f.file}.woff2') format('woff2'), url('${ttfDir}${f.file}.ttf') format('truetype');
      }'';

  # Generic CSS renderer. Supports fontFaces now; rules/keyframes etc. can be added.
  toCSS =
    {
      fontFaces ? [ ],
      ...
    }:
    lib.strings.concatStringsSep "\n\n" (map renderFontFace fontFaces);

  # High-level shorthand: takes compact font-face data, expands it, renders to CSS.
  #   Input: { family, display, dir, dirWoff2, dirTtf, prefix, variants }
  #   Output: CSS text string (all @font-face blocks joined)
  fontFacesToCSS = data: toCSS { fontFaces = mkFontFaces data; };

in
{

  inherit
    hexToRgb
    hexToHsl
    lerpColor
    hexToAnsi
    ansiReset
    mkFontFaces
    renderFontFace
    toCSS
    fontFacesToCSS
    ;

  colors = {
    # Catpuccin-Mocha Colour
    rosewater.hex = "#f5e0dc";
    flamingo.hex = "#f2cdcd";
    pink.hex = "#f5c2e7";
    mauve.hex = "#cba6f7";
    red.hex = "#f38ba8";
    maroon.hex = "#eba0ac";
    peach.hex = "#fab387";
    yellow.hex = "#f9e2af";
    green.hex = "#a6e3a1";
    teal.hex = "#94e2d5";
    sky.hex = "#89dceb";
    sapphire.hex = "#74c7ec";
    blue.hex = "#89b4fa";
    lavender.hex = "#b4befe";

    # Catpuccin Greyscale
    text.hex = "#cdd6f4";
    subtext1.hex = "#bac2de";
    subtext0.hex = "#a6adc8";
    overlay2.hex = "#9399b2";
    overlay1.hex = "#7f849c";
    overlay0.hex = "#6c7086";
    surface2.hex = "#585b70";
    surface1.hex = "#45475a";
    surface0.hex = "#313244";
    base.hex = "#1e1e2e";
    mantle.hex = "#181825";
    crust.hex = "#11111b";

    # SHES TRANS???
    tblue.hex = "#5BCEFA";
    tpink.hex = "#F5A9B8";

    # Saturated
    white.hex = "#ffffff";
    black.hex = "#000000";
    rgb-blue.hex = "#0000ff";
    rgb-red.hex = "#ff0000";
    rgb-green.hex = "#00ff00";
  };

  # Auto-import all image files from ./wallpapers/ as wallpapers.<name>
  wallpapers =
    let
      inherit (builtins)
        readDir
        match
        attrNames
        foldl'
        ;
      imageExts = [
        ".jpg"
        ".jpeg"
        ".png"
        ".gif"
        ".webp"
        ".bmp"
        ".svg"
      ];
      dirContents = readDir ./wallpapers;
      imageFiles = lib.filterAttrs (
        name: type: type == "regular" && builtins.any (ext: lib.strings.hasSuffix ext name) imageExts
      ) dirContents;
      stripExt =
        name:
        let
          m = match "(.*)\\.(jpg|jpeg|png|gif|webp|bmp|svg)" name;
        in
        if m == null then name else builtins.head m;
    in
    foldl' (acc: name: acc // { "${stripExt name}" = ./wallpapers + "/${name}"; }) { } (
      attrNames imageFiles
    );

}
