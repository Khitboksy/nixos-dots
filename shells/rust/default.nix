{ pkgs, ... }:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    rustc
    cargo
    clippy
    rustfmt
    rust-analyzer
    cargo-watch
    cargo-insta
    gcc
  ];
  shellHook = ''
    echo "rust dev environment"
    echo "  cargo fmt: rustfmt"
    echo "  lint: clippy"
    echo "  version: rustc --version"
    echo "  watch: cargo watch -x check"
    echo "  run: cargo run"
  '';
}
