{
  lib,
  zenith,
  config,
  pkgs,
  ...
}:

with zenith.lib';

let
  cfg = config.services.music;
in

{
  options.services.music = {
    enable = mkBoolOpt false "Enable Navidrome music streaming server";

    musicDirectory = mkStringOpt "/var/lib/navidrome/music" "Path to the music directory Navidrome serves";
  };

  config = lib.mkIf cfg.enable {
    services.navidrome = {
      enable = true;
      # Last.fm scrobbling for the Substreamer/RMPC clients. The API key and
      # shared secret live in a sops env file (ND_LASTFM_APIKEY/ND_LASTFM_SECRET)
      # so they stay out of the world-readable Nix store.
      environmentFile = config.sops.secrets.navidrome-lastfm.path;
      settings = {
        MusicFolder = cfg.musicDirectory;
        Address = "0.0.0.0";
        Port = 4533;
        EnableInsightsCollector = false;
        LastFM.Enabled = true;
      };
    };

    # Navidrome runs chrooted (RootDirectory=/run/navidrome) with only
    # MusicFolder bind-mounted into the sandbox. The lyrics mirror tree
    # must be visible inside the chroot too: the colocated .lrc files in
    # the music library are symlinks into it (../../../lyrics/...), and
    # without this bind their targets are ENOENT inside the sandbox --
    # Navidrome silently reports "no lyrics" for every sidecar track.
    # Read-only: Navidrome never writes lyrics itself.
    systemd.services.navidrome.serviceConfig.BindReadOnlyPaths = [ "/srv/lyrics" ];

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
