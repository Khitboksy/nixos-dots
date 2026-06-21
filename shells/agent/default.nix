{ pkgs, ... }:
pkgs.mkShell {
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
  RULES = "Format Nix files (nixfmt <file> or nix fmt) before writing. Run nix flake check after changes.";
  shellHook = ''
    echo "Agent environment for builds/"
    echo "  formatter: nixfmt (call: nixfmt <file>)"
    echo "  linters: statix, deadnix (call: statix check, deadnix)"
    echo "  build: nh os switch"
    echo "  verify: nix flake check"
  '';
}
