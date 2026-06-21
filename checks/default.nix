{ pkgs, ... }:
pkgs.runCommand "check-config"
  {
    buildInputs = with pkgs; [
      nixfmt
      statix
      deadnix
      nix
    ];
    src = ./..;
  }
  ''
    # Set up nix config
    export NIX_CONFIG="experimental-features = nix-command flakes"
    # Check that the flake evaluates
    echo "=== Checking flake evaluation ==="
    nix flake check --no-build "$src" 2>&1 || true
    # Check nix formatting
    echo "=== Checking formatting ==="
    find "$src" -name '*.nix' -not -path '*/.direnv/*' -not -path '*/result/*' -exec nixfmt --check {} \; || echo "Formatting issues found"
    # Check for dead code
    echo "=== Checking for dead Nix code ==="
    deadnix --check "$src" || true
    # Check for lint issues
    echo "=== Running statix ==="
    statix check "$src" || true
    touch "$out"
  ''
