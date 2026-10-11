{
  pkgs,
  ...
}:

{
  rust-eac-bypass = pkgs.writeShellScriptBin "rust-eac-bypass" ''
    declare -a args=()
    for arg in "$@"; do
      if [[ "$arg" =~ Rust\.exe$ ]] || [[ "$arg" =~ rust\.exe$ ]]; then
        args+=("''${arg/%Rust.exe/RustClient.exe}")
      else
        args+=("$arg")
      fi
    done
    exec "''${args[@]}"
  '';

}
