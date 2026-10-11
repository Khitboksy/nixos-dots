{
  config,
  lib,
  zenith,
  pkgs,
  ...
}:

with zenith.lib';

let

  cfg = config.apps.music.rmpc;

  incrementPlayCount =
    builtins.readFile ./config/utils/incrementPlayCount.sh
    |> pkgs.writeShellScript "rmpc-increment-playcount";

  fetchLyrics = pkgs.writeShellScript "rmpc-fetch-lyrics" ''
    DANKLRC="${lib.getExe pkgs.custom.danklrc}"
    RMPC="${lib.getExe' pkgs.rmpc "rmpc"}"
    ${builtins.readFile ./config/utils/fetch_album_lyrics.sh}
  '';

in
{
  options.apps.music.rmpc = with lib.types; {
    enable = mkBoolOpt false "Enable RMPC Rust Based CLI Music Player";
    lyricsDir = mkStringOpt' null;
    rmpcd = mkBoolOpt true "Enable rmpcd daemon (song_change trigger with full MPD metadata for lyric fetches)";
    lyricAuthor = mkBoolOpt false "LRC authoring mode: centisecond timestamps, 100ms status polling and seek step";
  };

  config = lib.mkIf cfg.enable {

    home.packages = lib.optionals cfg.rmpcd [ pkgs.rmpcd ];

    systemd.user.services.rmpcd = lib.mkIf cfg.rmpcd {
      Unit = {
        Description = "rmpcd companion daemon for rmpc/MPD";
        After = [ "mpd.service" ];
        PartOf = [ "mpd.service" ];
      };
      Service = {
        ExecStart = "${lib.getExe' pkgs.rmpcd "rmpcd"}";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "default.target" ];
    };

    xdg.configFile = {

      "rmpc/themes/helios.ron" = {
        text = import ./config/themes/helios.nix {
          inherit zenith;
          inherit (cfg) lyricAuthor;
        };
      };

      "rmpcd/init.lua" = lib.mkIf cfg.rmpcd {
        text = ''
          -- Managed by home-manager (apps.music.rmpc).
          ---@type Config
          local config = {
              address = "127.0.0.1:6600",
          }

          rmpcd.install("plugins.danklrc"):setup({
              script = "${fetchLyrics}",
          })

          return config
        '';
      };

      "rmpcd/plugins/danklrc.lua" = lib.mkIf cfg.rmpcd {
        text = ''
          -- Managed by home-manager (apps.music.rmpc).
          ---@class DanklrcArgs
          ---@field script string Path of the lyrics fetch script to spawn.
          ---@class DanklrcPlugin:RmpcdPlugin<DanklrcArgs>
          ---@field script string|nil
          ---@type DanklrcPlugin
          local M = {}

          M.setup = function(self, args)
              if args.script then
                  self.script = args.script
              end
          end

          M.song_change = function(self, _old_song, new_song)
              if new_song == nil or self.script == nil then
                  return
              end
              local title = (new_song.title and new_song.title:first()) or ""
              local artist = (new_song.artist and new_song.artist:first()) or ""
              local album = (new_song.album and new_song.album:first()) or ""
              local duration = math.floor((new_song.duration or 0) / 1000)

              process.spawn({
                  self.script,
                  "--rmpcd",
                  new_song.file,
                  title,
                  artist,
                  album,
                  tostring(duration),
              })
          end

          return M
        '';
      };
    };

    programs.rmpc = {
      package = pkgs.rmpc;
      enable = true;

      config = ''
        #![enable(implicit_some)]
        #![enable(unwrap_newtypes)]
        #![enable(unwrap_variant_newtypes)]


        (
            address: "127.0.0.1:6600",
            password: None,
            theme: Some("~/.config/rmpc/themes/helios.ron"),
            lyrics_dir: Some("${cfg.lyricsDir}"),
        	  enable_config_hot_reload: true,
            cache_dir: None,


            on_song_change: [
              "${lib.getExe pkgs.bash}", "-c",
              "${incrementPlayCount}; ${fetchLyrics}"
            ],
            enable_lyrics_hot_reload: true,


            volume_step: 5,
            max_fps: 30,
            scrolloff: 0,
            wrap_navigation: false,
            enable_mouse: true,
            status_update_interval_ms: ${if cfg.lyricAuthor then "100" else "1000"},
            seek_step_ms: ${if cfg.lyricAuthor then "100" else "5000"},
            select_current_song_on_change: false,


            album_art: (
                method: Auto,
                max_size_px: (width: 500, height: 500),
                disabled_protocols: ["http://", "https://"],
                vertical_align: Center,
                horizontal_align: Center,
            ),


            keybinds: (

                global: {
                    ":":       CommandMode,
                    ",":       VolumeDown,
                    ".":       VolumeUp,
                    "<Tab>":   NextTab,
                    "<S-Tab>": PreviousTab,
                    "1":       SwitchToTab("Playing"),
                    "4":       SwitchToTab("Dir"),
                    "3":       SwitchToTab("Lists"),
                    "2":       SwitchToTab("Find"),
                    "q":       Quit,
                    "p":       TogglePause,
                    "s":       Stop,
                    "<":       PreviousTrack,
                    ">":       NextTrack,
                    "f":       SeekForward,
                    "b":       SeekBack,
                    "v":       ToggleSingle,
                    "z":       ToggleRepeat,
                    "x":       ToggleRandom,
                    "c":       ToggleConsume,
                    "~":       ShowHelp,
                    "I":       ShowCurrentSongInfo,
                    "O":       ShowOutputs,
                    "P":       ShowDecoders,
                },


                navigation: {
                    "k":         Up,
                    "j":         Down,
                    "h":         Left,
                    "l":         Right,
                    "<Up>":      Up,
                    "<Down>":    Down,
                    "<Left>":    Left,
                    "<Right>":   Right,
                    "<C-k>":     PaneUp,
                    "<C-j>":     PaneDown,
                    "<C-h>":     PaneLeft,
                    "<C-l>":     PaneRight,
                    "<C-u>":     UpHalf,
                    "N":         PreviousResult,
                    "a":         Add,
                    "A":         AddAll,
                    "r":         Rename,
                    "n":         NextResult,
                    "g":         Top,
                    "<Space>":   Select,
                    "<C-Space>": InvertSelection,
                    "G":         Bottom,
                    "<CR>":      Confirm,
                    "i":         FocusInput,
                    "J":         MoveDown,
                    "<C-d>":     DownHalf,
                    "/":         EnterSearch,
                    "<C-c>":     Close,
                    "<Esc>":     Close,
                    "K":         MoveUp,
                    "D":         Delete,
                },


                queue: {
                    "D":       DeleteAll,
                    "<CR>":    Play,
                    "<C-s>":   Save,
                    "a":       AddToPlaylist,
                    "d":       Delete,
                    "i":       ShowInfo,
                    "C":       JumpToCurrent,
                },

            ),


            search: (

                case_sensitive: false,
                mode: Contains,


                tags: [
                    (value: "any",         label: "Any Tag"),
                    (value: "title",       label: "Title"),
                    (value: "album",       label: "Album"),
                    (value: "artist",      label: "Artist"),
                    (value: "filename",    label: "Filename"),
                    (value: "genre",       label: "Genre"),
                ],

            ),


            artists: (
                album_display_mode: SplitByDate,
                album_sort_by: Date,
            ),


            cava: (

                framerate: 165,
                autosens: true,
                sensitivity: 200,


                input: (
                    method: Fifo,
                    source: "/tmp/mpd.fifo",
                    sample_rate: 44100,
                    channels: 2,
                    sample_bits: 16,
                ),


                smoothing: (
                    noise_reduction: 0,
                ),


                eq: []

            ),


            tabs: [
                (
                    name: "Playing",
                    pane: Component("playing_tab"),
                ),
                (
                    name: "Find",
                    pane: Pane(Search),
                ),
               (
                    name: "Lists",
                    pane: Pane(Playlists),
                ),
               (
                    name: "Dir",
                    pane: Pane(Directories),
                ),
            ],
        )
      '';
    };
  };
}
