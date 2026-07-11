{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.services.music;
in

{
  options.services.music = {
    enable = mkBoolOpt false "Enable Navidrome music streaming server";

    musicDirectory = mkStringOpt "/var/lib/navidrome/music" "Path to the music directory Navidrome serves";
  };

  config = mkIf cfg.enable {
    services.navidrome = {
      enable = true;
      settings = {
        MusicFolder = cfg.musicDirectory;
        Address = "0.0.0.0";
        Port = 4533;
        EnableInsightsCollector = false;
      };
    };

    # Ensure the music directory exists with the right ownership.
    # When using a custom path (e.g. an NFS mount), the tmpfiles entry
    # will fail harmlessly if the directory is already mounted there --
    # that's fine, the directory already exists from the mount.
    systemd.tmpfiles.settings."10-navidrome-music" = {
      "${cfg.musicDirectory}".d = {
        user = "helios";
        group = "users";
        mode = "0755";
      };
    };
  };
}
