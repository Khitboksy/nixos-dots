{
  img2key,
  rmpc,
  yazi,
  zen-browser,
  niri-src,
  mcp-nixos,
  ...
}:

final: prev:
let
  system = final.stdenv.hostPlatform.system;
in
{
  img2key = img2key.packages.${system}.default;
  rmpc = rmpc.packages.${system}.default;
  yazi = yazi.packages.${system}.default;
  zen = zen-browser.packages.${system}.default;
  niri = niri-src.packages.${system}.default;
  mcp-nixos = mcp-nixos.packages.${system}.default;
}
