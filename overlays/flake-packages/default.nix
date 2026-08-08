{
  img2key,
  rmpc,
  yazi,
  zen-browser,
  niri-src,
  mcp-nixos,
  ...
}:

final: prev: {
  img2key = img2key.packages.${final.system}.default;
  rmpc = rmpc.packages.${final.system}.default;
  yazi = yazi.packages.${final.system}.default;
  zen = zen-browser.packages.${final.system}.default;
  niri = niri-src.packages.${final.system}.default;
  mcp-nixos = mcp-nixos.packages.${final.system}.default;
}
