{ lib, theme }:
let
  inherit (builtins) readDir attrNames filter;

  # Discover available themes for validation
  dirContents = readDir ./.;
  themeDirs = filter (name: dirContents.${name} == "directory") (attrNames dirContents);

  # Validate the requested theme exists
  found = builtins.elem theme themeDirs;
  themeCss =
    if found then
      (import ./${theme}/gtk-theme.nix) { inherit lib; }
    else
      throw ''
        Theme "${theme}" not found in themes/.
        Available themes: ${builtins.concatStringsSep ", " themeDirs}
      '';
in
themeCss
