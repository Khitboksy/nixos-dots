{
  lib,
  config,
  ...
}:
with lib;
with lib.custom;
let
  cfg = config.rice;

  # Auto-discover available font directories
  dirContents = builtins.readDir ./.;
  fontDirs = builtins.filter (name: dirContents.${name} == "directory") (
    builtins.attrNames dirContents
  );

  # Only fonts the user explicitly enabled
  enabledFonts = builtins.filter (name: builtins.elem name cfg.fonts) fontDirs;

  # Generate @font-face CSS only for enabled fonts
  fontCss =
    if enabledFonts == [ ] then
      ""
    else
      lib.strings.concatStringsSep "\n\n" (
        map (
          name:
          fontFacesToCSS {
            family = name;
            prefix = name;
            dirWoff2 = "${name}/WOFF2/";
            dirTtf = "${name}/TTF/";
            variants = import ./variants.nix;
          }
        ) enabledFonts
      );
in
{
  options.rice.fonts = mkStringListOpt [ ] "Font families to enable for @font-face CSS";

  # Internal option consumed by rice/gtk module
  options.rice._fontsCss = mkOption {
    type = types.str;
    internal = true;
    default = "";
    description = "Generated @font-face CSS (internal)";
  };

  config.rice._fontsCss = fontCss;
}
