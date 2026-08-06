{ pkgs, ... }:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    nixfmt
    nixfmt-tree
    nixd
    statix
    deadnix
  ];
  shellHook = ''
    echo "nix dev environment"
    echo "  nix fmt: nixfmt"
    echo "  lsp: nixd"
    echo "  lint: statix, deadnix"
  '';
}
