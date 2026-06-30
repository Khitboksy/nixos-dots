{ pkgs, ... }:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    nixfmt
    nil
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
    echo "  lsp: nil"
    echo "  linters: statix, deadnix"
    echo "  build: nh os switch"
  '';
}
