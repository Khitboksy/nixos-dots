{
  config,
  lib,
  zenith,
  ...
}:

with zenith.lib';
let
  cfg = config.apps.music.discord-rpc;
in
{

  options.apps.music.discord-rpc = with lib.types; {
    enable = mkBoolOpt false "Enable MPD Discord Rich Presence (mpd-discord-rpc)";
  };

  config = lib.mkIf cfg.enable {
    # Sidecar daemon: watches MPD on localhost:6600 and pushes a
    # "Listening to ..." activity to Discord via the local IPC socket.
    # Independent of rmpc — any MPD client works.
    services.mpd-discord-rpc = {
      enable = true;
      settings = {
        # Own Discord application (dev portal), so presence is not tied to
        # the author's default app. Album covers are fetched dynamically
        # from Cover Art Archive; no static art assets are uploaded, hence
        # the empty image keys (they would reference assets that don't
        # exist in our application).
        id = 1555108678497992785;
        hosts = [ "localhost:6600" ];

        format = {
          details = "$title";
          state = "$artist / $album";
          timestamp = "both";
          large_image = "";
          small_image = "";
          large_text = "";
          small_text = "";

          # Buttons support $token expansion, but no URL-encoding is done
          # — a canonical last.fm/music/$artist/_/$title path would break
          # on spaces, so button 1 uses the search endpoint instead.
          button1_text = "View on Last.fm";
          button1_link = "https://www.last.fm/search?q=$artist+-+$title";
          button2_text = "My Last.fm";
          button2_link = "https://www.last.fm/user/khitboksy";
        };
      };
    };
  };

}
