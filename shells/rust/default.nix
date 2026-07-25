{ pkgs, ... }:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    rustc
    cargo
    clippy
    rustfmt
    cargo-watch
    cargo-insta
  ];
  shell = pkgs.fish;
  shellHook = ''
    fish
    echo "rust dev environment"
    echo "  version: rustc --version"
    echo "  check: cargo check"
    echo "  watch: cargo watch -x check"
    echo "  run: cargo run"
    echo "  release: cargo build --release"
    echo "  lint: cargo clippy"
    echo "  fmt: cargo fmt"
  '';
}
