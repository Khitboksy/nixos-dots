{ pkgs, ... }:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    nixfmt-tree
    nixd
    statix
    deadnix
  ];
  shellHook = ''
    echo "nix dev environment"
    echo "  nix fmt: nixfmt-tree"
    echo "  lsp: nixd"
    echo "  lint: statix, deadnix"
  '';
}
