{ pkgs, ... }:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    nixfmt
    nixd
    statix
    deadnix
    nixos-rebuild
    nh
    git
  ];
  NIX_FLAKE = "/home/helios/builds";
  NH_FLAKE = "/home/helios/builds";
  shellHook = ''
    echo "builds dev environment"
    echo "  formatter: nixfmt"
    echo "  lsp: nixd"
    echo "  build Helios: ns"
    echo "  build Terra: terra-depl"
  '';
}
