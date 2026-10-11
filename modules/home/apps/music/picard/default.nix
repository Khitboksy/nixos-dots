{
  config,
  lib,
  pkgs,
  zenith,
  ...
}:

with zenith.lib';

let
  cfg = config.apps.music.picard;
in

{
  options.apps.music.picard = with lib.types; {
    enable = mkBoolOpt false "Enable MusicBrainz Picard tagger";
  };

  config = lib.mkIf cfg.enable {
    # Fingerprint audio with AcoustID and write the MUSICBRAINZ_* tags that
    # Navidrome reads into MbzRecordingID and forwards to Last.fm as `mbid`.
    # Note the naming trap: MUSICBRAINZ_TRACKID holds the *recording* id
    # (legacy misnomer) and is the one Last.fm wants; MUSICBRAINZ_RELEASETRACKID
    # holds the track id and is never forwarded.
    #
    # Before saving, these three settings are load-bearing for this library:
    #   Options > File Naming: "Move files when saving"   -> OFF
    #   Options > File Naming: "Rename files when saving" -> OFF
    #   Options > Tags:        "Clear existing tags"      -> OFF
    # The Artist/Album layout is depended on by the lyrics symlinks, the cover
    # audit, slskd's share and Navidrome's MusicFolder -- and the hand-set
    # title/date/track tags must survive alongside the new MBIDs.
    #
    # Afterwards Navidrome has to rescan the library, or the new MBIDs stay
    # invisible to it (it caches tags at scan time).
    home.packages = with pkgs; [
      picard
    ];
  };
}
