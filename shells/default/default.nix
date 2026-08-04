{ pkgs, ... }:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    # Nix
    nixfmt-tree
    nixd
    statix
    deadnix

    # Lua
    stylua
    lua-language-server

    # Web / config
    prettierd
    taplo
    nodejs

    # Build / deploy
    nh
    git
  ];
  NIX_FLAKE = "/home/helios/builds";
  NH_FLAKE = "/home/helios/builds";
  shellHook = ''
    echo "builds dev environment"
    echo "  nix fmt: nixfmt-tree"
    echo "  lsp: nixd"
    echo "  lint: statix, deadnix"
    echo "  build Helios: ns"
    echo "  build Terra: terra-depl"
  '';
}
