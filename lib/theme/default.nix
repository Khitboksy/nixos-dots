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

  stripHash = lib.strings.removePrefix "#";

  hexToRgb =
    hexColor:
    let
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
    lerpColor
    ansiReset
    mkFontFaces
    renderFontFace
    toCSS
    fontFacesToCSS
    ;

  colors = {
    # Catpuccin-Mocha Colour
    rosewater = {
      hex = "#f5e0dc";
      hex' = stripHash "#f5e0dc";
      rgb = hexToRgb "#f5e0dc";
      hsl = hexToHsl "#f5e0dc";
      ansi = hexToAnsi "#f5e0dc";
    };
    flamingo = {
      hex = "#f2cdcd";
      hex' = stripHash "#f2cdcd";
      rgb = hexToRgb "#f2cdcd";
      hsl = hexToHsl "#f2cdcd";
      ansi = hexToAnsi "#f2cdcd";
    };
    pink = {
      hex = "#f5c2e7";
      hex' = stripHash "#f5c2e7";
      rgb = hexToRgb "#f5c2e7";
      hsl = hexToHsl "#f5c2e7";
      ansi = hexToAnsi "#f5c2e7";
    };
    mauve = {
      hex = "#cba6f7";
      hex' = stripHash "#cba6f7";
      rgb = hexToRgb "#cba6f7";
      hsl = hexToHsl "#cba6f7";
      ansi = hexToAnsi "#cba6f7";
    };
    red = {
      hex = "#f38ba8";
      hex' = stripHash "#f38ba8";
      rgb = hexToRgb "#f38ba8";
      hsl = hexToHsl "#f38ba8";
      ansi = hexToAnsi "#f38ba8";
    };
    maroon = {
      hex = "#eba0ac";
      hex' = stripHash "#eba0ac";
      rgb = hexToRgb "#eba0ac";
      hsl = hexToHsl "#eba0ac";
      ansi = hexToAnsi "#eba0ac";
    };
    peach = {
      hex = "#fab387";
      hex' = stripHash "#fab387";
      rgb = hexToRgb "#fab387";
      hsl = hexToHsl "#fab387";
      ansi = hexToAnsi "#fab387";
    };
    yellow = {
      hex = "#f9e2af";
      hex' = stripHash "#f9e2af";
      rgb = hexToRgb "#f9e2af";
      hsl = hexToHsl "#f9e2af";
      ansi = hexToAnsi "#f9e2af";
    };
    green = {
      hex = "#a6e3a1";
      hex' = stripHash "#a6e3a1";
      rgb = hexToRgb "#a6e3a1";
      hsl = hexToHsl "#a6e3a1";
      ansi = hexToAnsi "#a6e3a1";
    };
    teal = {
      hex = "#94e2d5";
      hex' = stripHash "#94e2d5";
      rgb = hexToRgb "#94e2d5";
      hsl = hexToHsl "#94e2d5";
      ansi = hexToAnsi "#94e2d5";
    };
    sky = {
      hex = "#89dceb";
      hex' = stripHash "#89dceb";
      rgb = hexToRgb "#89dceb";
      hsl = hexToHsl "#89dceb";
      ansi = hexToAnsi "#89dceb";
    };
    sapphire = {
      hex = "#74c7ec";
      hex' = stripHash "#74c7ec";
      rgb = hexToRgb "#74c7ec";
      hsl = hexToHsl "#74c7ec";
      ansi = hexToAnsi "#74c7ec";
    };
    blue = {
      hex = "#89b4fa";
      hex' = stripHash "#89b4fa";
      rgb = hexToRgb "#89b4fa";
      hsl = hexToHsl "#89b4fa";
      ansi = hexToAnsi "#89b4fa";
    };
    lavender = {
      hex = "#b4befe";
      hex' = stripHash "#b4befe";
      rgb = hexToRgb "#b4befe";
      hsl = hexToHsl "#b4befe";
      ansi = hexToAnsi "#b4befe";
    };

    # Catpuccin Greyscale
    text = {
      hex = "#cdd6f4";
      hex' = stripHash "#cdd6f4";
      rgb = hexToRgb "#cdd6f4";
      hsl = hexToHsl "#cdd6f4";
      ansi = hexToAnsi "#cdd6f4";
    };
    subtext1 = {
      hex = "#bac2de";
      hex' = stripHash "#bac2de";
      rgb = hexToRgb "#bac2de";
      hsl = hexToHsl "#bac2de";
      ansi = hexToAnsi "#bac2de";
    };
    subtext0 = {
      hex = "#a6adc8";
      hex' = stripHash "#a6adc8";
      rgb = hexToRgb "#a6adc8";
      hsl = hexToHsl "#a6adc8";
      ansi = hexToAnsi "#a6adc8";
    };
    overlay2 = {
      hex = "#9399b2";
      hex' = stripHash "#9399b2";
      rgb = hexToRgb "#9399b2";
      hsl = hexToHsl "#9399b2";
      ansi = hexToAnsi "#9399b2";
    };
    overlay1 = {
      hex = "#7f849c";
      hex' = stripHash "#7f849c";
      rgb = hexToRgb "#7f849c";
      hsl = hexToHsl "#7f849c";
      ansi = hexToAnsi "#7f849c";
    };
    overlay0 = {
      hex = "#6c7086";
      hex' = stripHash "#6c7086";
      rgb = hexToRgb "#6c7086";
      hsl = hexToHsl "#6c7086";
      ansi = hexToAnsi "#6c7086";
    };
    surface2 = {
      hex = "#585b70";
      hex' = stripHash "#585b70";
      rgb = hexToRgb "#585b70";
      hsl = hexToHsl "#585b70";
      ansi = hexToAnsi "#585b70";
    };
    surface1 = {
      hex = "#45475a";
      hex' = stripHash "#45475a";
      rgb = hexToRgb "#45475a";
      hsl = hexToHsl "#45475a";
      ansi = hexToAnsi "#45475a";
    };
    surface0 = {
      hex = "#313244";
      hex' = stripHash "#313244";
      rgb = hexToRgb "#313244";
      hsl = hexToHsl "#313244";
      ansi = hexToAnsi "#313244";
    };
    base = {
      hex = "#1e1e2e";
      hex' = stripHash "#1e1e2e";
      rgb = hexToRgb "#1e1e2e";
      hsl = hexToHsl "#1e1e2e";
      ansi = hexToAnsi "#1e1e2e";
    };
    mantle = {
      hex = "#181825";
      hex' = stripHash "#181825";
      rgb = hexToRgb "#181825";
      hsl = hexToHsl "#181825";
      ansi = hexToAnsi "#181825";
    };
    crust = {
      hex = "#11111b";
      hex' = stripHash "#11111b";
      rgb = hexToRgb "#11111b";
      hsl = hexToHsl "#11111b";
      ansi = hexToAnsi "#11111b";
    };

    # SHES TRANS???
    tblue = {
      hex = "#5BCEFA";
      hex' = stripHash "#5BCEFA";
      rgb = hexToRgb "#5BCEFA";
      hsl = hexToHsl "#5BCEFA";
      ansi = hexToAnsi "#5BCEFA";
    };
    tpink = {
      hex = "#F5A9B8";
      hex' = stripHash "#F5A9B8";
      rgb = hexToRgb "#F5A9B8";
      hsl = hexToHsl "#F5A9B8";
      ansi = hexToAnsi "#F5A9B8";
    };

    # Saturated
    white = {
      hex = "#ffffff";
      hex' = stripHash "#ffffff";
      rgb = hexToRgb "#ffffff";
      hsl = hexToHsl "#ffffff";
      ansi = hexToAnsi "#ffffff";
    };
    black = {
      hex = "#000000";
      hex' = stripHash "#000000";
      rgb = hexToRgb "#000000";
      hsl = hexToHsl "#000000";
      ansi = hexToAnsi "#000000";
    };
    rgb-blue = {
      hex = "#0000ff";
      hex' = stripHash "#0000ff";
      rgb = hexToRgb "#0000ff";
      hsl = hexToHsl "#0000ff";
      ansi = hexToAnsi "#0000ff";
    };
    rgb-red = {
      hex = "#ff0000";
      hex' = stripHash "#ff0000";
      rgb = hexToRgb "#ff0000";
      hsl = hexToHsl "#ff0000";
      ansi = hexToAnsi "#ff0000";
    };
    rgb-green = {
      hex = "#00ff00";
      hex' = stripHash "#00ff00";
      rgb = hexToRgb "#00ff00";
      hsl = hexToHsl "#00ff00";
      ansi = hexToAnsi "#00ff00";
    };
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
