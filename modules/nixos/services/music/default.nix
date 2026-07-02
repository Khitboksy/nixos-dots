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
  musicDir = "/var/lib/navidrome/music";
in

{
  options.services.music = with types; {
    enable = mkBoolOpt false "Enable Navidrome music streaming server";
  };

  config = mkIf cfg.enable {
    services.navidrome = {
      enable = true;
      settings = {
        MusicFolder = musicDir;
        Address = "0.0.0.0";
        Port = 4533;
        EnableInsightsCollector = false;
      };
    };

    # Ensure the music directory exists with the right ownership.
    # Navidrome needs to read/write its own data (DB, cache) plus
    # read the music files placed here.
    systemd.tmpfiles.settings."10-navidrome-music" = {
      "${musicDir}".d = {
        user = "navidrome";
        group = "navidrome";
        mode = "0755";
      };
    };
  };
}
