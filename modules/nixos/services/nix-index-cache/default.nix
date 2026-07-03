{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.programs.nix-index;
in

{
  options.programs.nix-index = with types; {
    useTerra = mkBoolOpt false "Sync nix-index database from terra at boot via rsync";
  };

  config = mkIf cfg.useTerra {
    systemd.user.services.nix-index-cache = {
      description = "Sync nix-index database from terra";
      wantedBy = [ "default.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${pkgs.rsync}/bin/rsync -az --timeout=5 \
          -e "${pkgs.openssh}/bin/ssh -i /home/helios/.ssh/id_ed25519_nix-index" \
          helios@terra:.cache/nix-index/files \
          "$HOME/.cache/nix-index/files" \
          || true
      '';
    };
  };
}
