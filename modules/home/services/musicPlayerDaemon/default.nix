{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.services.musicPlayerDaemon;
in

{
  options.services.musicPlayerDaemon = with types; {
    enable = mkBoolOpt false "Enable MPD";
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      mpd
      mpd-mpris
    ];

    systemd.user.services.mpd-mpris = {
      Unit = {
        Description = "MPRIS bridge for MPD";
        After = [ "mpd.service" ];
        PartOf = [ "mpd.service" ];
      };
      Service = {
        ExecStart = "${getExe pkgs.mpd-mpris} mpd";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "default.target" ];
    };

    services = {

      mpd = {
        enable = true;
        musicDirectory = "/mnt/nix-data/media/music/";
        network.listenAddress = "127.0.0.1";
        network.port = 6600;

        extraConfig = ''
          audio_output {
            type  "pulse"
            name  "PipeWire Output"
            format "44100:16:2"
          }
          audio_output {
            type   "fifo"
            name   "my_fifo"
            path   "/tmp/mpd.fifo"
            format "44100:16:2"
          }
        '';
      };

      mpdscribble = {
        enable = true;
        endpoints = {
          "last.fm" = {
            passwordFile = "/run/secrets/lastfm";
            username = "khitboksy";
          };
        };

      };

    };

  };
}
