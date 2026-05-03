{
  lib,
  config,
  ...
}:
with lib;
with lib.custom;
let
  q = s: "\"${s}\"";
in

''
  #![enable(implicit_some)]
  #![enable(unwrap_newtypes)]
  #![enable(unwrap_variant_newtypes)]

  (

    text_color: ${q colors.text.hex},
    background_color: None,
    header_background_color: None,
    modal_background_color: None,


    preview_label_style:
    (
      fg: ${q colors.yellow.hex},
      bg: None
    ),

    
    preview_metadata_group_style:
    (
      fg: ${q colors.yellow.hex},
      bg: None,
      modifiers: "Bold"
    ),

    
    highlighted_item_style:
    (
      fg: ${q colors.mauve.hex},
      bg: None,
      modifiers: "Bold"
    ),


    current_item_style:
    (
      fg: ${q colors.mauve.hex},
      bg: ${q colors.surface1.hex},
      modifiers: "Bold"
    ),


    borders_style: 
    (
      fg: ${q colors.overlay2.hex},
      bg: None
    ),


    highlight_border_style:
    (
      fg: ${q colors.text.hex},
      bg: None
    ),


    tab_bar: (

      active_style: 
      (
        fg: ${q colors.base.hex},
        bg: ${q colors.mauve.hex},
        modifiers: "Bold"
      ),

      inactive_style:
      (
        fg: ${q colors.text.hex},
        bg: None
      ),
    ),


    level_styles: (

      info:
      (
        fg: ${q colors.mauve.hex},
        bg: ${q colors.base.hex}
      ),

      warn:
      (
        fg: ${q colors.yellow.hex},
        bg: ${q colors.base.hex}
      ),
      
      error:
      (
        fg: ${q colors.red.hex},
        bg: ${q colors.base.hex}
      ),
      
      debug:
      (
        fg: ${q colors.green.hex},
        bg: ${q colors.base.hex}
      ),
      
      trace:
      (
        fg: ${q colors.lavender.hex}, 
        bg: ${q colors.base.hex}
      ),
    ),


    default_album_art_path: None,
    show_song_table_header: false,
    draw_borders: false,
    format_tag_separator: " | ",
    browser_column_widths: [20, 38, 42],
    modal_backdrop: false,

        
    symbols:
    (
      song: "󰝚 ",
      dir: "󰀥 ",
      playlist: "󰲸 ",
      marker: "▶︎ ",
      ellipsis: "... ",
      song_style: None,
      dir_style: None,
      playlist_style: None,
    ),


    progress_bar: 
    (
      symbols: ["█", "█", "", "█", "█"],

      track_style:
      (
        fg: ${q colors.mantle.hex}
      ),

      elapsed_style:
      (
        fg: ${q colors.mauve.hex}
      ),

      thumb_style:
      (
        fg: ${q colors.mauve.hex},
        bg: ${q colors.mantle.hex}
      ),


      text: Some(Group([
      (
        kind: Property(Artist), 
          style:
          (
            fg: ${q colors.rosewater.hex},
            modifiers: "Bold")
          ),

          (
            kind: Text(" - "), 
              style:
              (
                fg: ${q colors.rosewater.hex}
              )
          ),

          (
            kind: Property(Title),
              style:
              (
                fg: ${q colors.rosewater.hex},
                modifiers: "Bold"
              )
          ),
        ])),
      ),

    scrollbar: None,

    song_table_format: [

        (
          prop: (
            kind: Sticker("playCount"),
            style: (fg: ${q colors.peach.hex}),
            default: (
              kind: Text("0"),
              style: (fg: ${q colors.peach.hex})
            )
          ),
          width: "4",
          alignment: Right,
          label: "Playcount"
        ),

        (
          prop: (
            kind: Property(Artist),
            style: (fg: ${q colors.mauve.hex}, modifiers: "Bold"),
            default: (
              kind: Text("Unknown"),
              style: (fg: ${q colors.mauve.hex}, modifiers: "Bold")
            )
          ),
          width: "35%",
          alignment: Right
        ),

        (
          prop: (
            kind: Text("-"),
            style: (fg: ${q colors.text.hex}),
            default: (
              kind: Text("Unknown")
            )
          ),
          width: "1",
          alignment: Center
        ),

        (
          prop: (
            kind: Property(Title),
            style: (fg: ${q colors.blue.hex}),
            current_style: (fg: ${q colors.mauve.hex}, modifiers: "Bold"),
            default: (
              kind: Text("Unknown"),
              style: (fg: ${q colors.blue.hex}),
              current_style: (fg: ${q colors.mauve.hex}, modifiers: "Bold")
            )
          ),
          width: "65%",
          alignment: Left
        )
      ],
        components: {},

        layout: Split(
            direction: Vertical,
            panes: [

                (
                    pane: Pane(Tabs),
                    size: "3",
                ),

                (
                    pane: Pane(TabContent),
                    size: "100%",
                ),

                (
                    pane: Pane(ProgressBar),
                    size: "1",
                ),
            ],
        ),

        browser_song_format: [

                (
                kind: 
                  Group([
                    (kind: Property(Track)),
                    (kind: Text(" ")),
                  ])
                ),

                (
                kind: Group([
                    (kind: Property(Artist)),
                    (kind: Text(" - ")),
                    (kind: Property(Title)),
                ]),
                default: (kind: Property(Filename))
            ),

        ],


    cava: (

        // Upwards
        bar_symbols: ['▁', '▂', '▃', '▄', '▅', '▆', '▇', '█'],
        // Downards
        inverted_bar_symbols: ['▔', '🮂', '🮃', '▀', '🮄', '🮅', '🮆', '█'],

        bars: 60,
        bar_width: 1, // width of a single bar in columns
        bar_spacing: 1, // free space between bars in columns

        // Possible values are "Top", "Bottom" and "Horizontal".
        orientation: Horizontal,

        bar_color: Gradient({
          12: ${q colors.mauve.hex},
          22: ${q colors.lavender.hex},
          36: ${q colors.blue.hex},
          50: ${q colors.sapphire.hex},
          66: ${q colors.sky.hex},
          82: ${q colors.teal.hex},
          100: ${q colors.green.hex}
        }),

      ),
        lyrics: (
            timestamp: false
        )
      )
''
