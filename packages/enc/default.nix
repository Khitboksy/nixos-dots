{
  lib,
  writeShellScriptBin,
  gnupg,
  neovim,
  coreutils,
  wl-clipboard-rs,
  xclip,
  sops,
}:
writeShellScriptBin "enc" ''
  #!${coreutils}/bin/env zsh

  repo_root="$HOME/gh/kh/nd"
  secrets_dir="''${SOPS_SECRETS_DIR:-$repo_root/secrets}"
  export SOPS_AGE_KEY_FILE=/etc/sops/keys.txt

  usage() {
      echo "Usage:"
      echo "  $0 <secret-name>                  Edit or create a sops secret in $secrets_dir"
      echo "  $0 -m recipient1@example.com ...  Encrypt a message (gpg) to clipboard"
      echo ""
      echo "Secrets in $secrets_dir:"
      ls -1 "$secrets_dir"
  }

  if [[ "$1" == "-m" || "$1" == "--message" ]]; then
      shift

      if [[ $# -eq 0 ]]; then
          echo "Usage: $0 -m recipient1@example.com [recipient2@example.com ...]"
          exit 1
      fi

      # Create a temporary file
      temp_file=$(${coreutils}/bin/mktemp)
      trap "${coreutils}/bin/rm -f $temp_file $temp_file.asc" EXIT

      # Create recipient arguments for gpg
      recipients=()
      recipients+=("-r" "0x8400E0C831E87082")
      for recipient in "$@"; do
          recipients+=("-r" "$recipient")
      done

      # Open neovim with the temp file
      ${neovim}/bin/nvim \
           -c "set noswapfile" \
           -c "set filetype=" \
           "$temp_file"

      # Check if the temp file has content after nvim closes
      if [[ -s "$temp_file" ]]; then
          # Encrypt the content with gpg and copy to clipboard
          if [[ -n "$WAYLAND_DISPLAY" ]]; then
              ${gnupg}/bin/gpg --encrypt \
                  --armor \
                  --trust-model always \
                  "''${recipients[@]}" \
                  "$temp_file"

              cat "$temp_file".asc | ${wl-clipboard-rs}/bin/wl-copy --type text/plain
              echo "Encrypted content copied to Wayland clipboard"
          elif [[ -n "$DISPLAY" ]]; then
              ${gnupg}/bin/gpg --encrypt \
                  --armor \
                  --trust-model always \
                  "''${recipients[@]}" \
                  "$temp_file"
              cat "$temp_file.asc" | ${xclip}/bin/xclip -selection clipboard
              echo "Encrypted content copied to X11 clipboard"
          else
              echo "No display detected, cannot copy to clipboard"
              exit 1
          fi
      else
          echo "No content was saved, exiting."
      fi

      exit 0
  fi

  if [[ "$1" == "-h" || "$1" == "--help" || $# -eq 0 ]]; then
      usage
      exit 0
  fi

  name="$1"
  if [[ "$name" == */* ]]; then
      echo "Secret name must not contain '/'; secrets live in $secrets_dir"
      exit 1
  fi
  target="$secrets_dir/$name"

  # Create a temporary file
  temp_file=$(${coreutils}/bin/mktemp)
  trap "${coreutils}/bin/rm -f $temp_file" EXIT

  # Decrypt the existing secret into the temp file, if it exists
  if [[ -f "$target" ]]; then
      (cd "$repo_root" && ${lib.getExe sops} -d "$target") > "$temp_file" || {
          echo "Failed to decrypt $target"
          exit 1
      }
  fi

  # Open neovim with the temp file
  ${neovim}/bin/nvim \
       -c "set noswapfile" \
       -c "set filetype=" \
       "$temp_file"

  # Check if the temp file has content after nvim closes
  if [[ -s "$temp_file" ]]; then
      # Encrypt the content with sops and write it to the secrets dir
      if (cd "$repo_root" && ${lib.getExe sops} -e "$temp_file") > "$target.tmp" \
          && ${coreutils}/bin/mv "$target.tmp" "$target"; then
          echo "Encrypted secret saved to $target"
      else
          ${coreutils}/bin/rm -f "$target.tmp"
          echo "Failed to encrypt secret"
          exit 1
      fi
  else
      echo "No content was saved, exiting."
  fi
''
