{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.custom;
let
  cfg = config.apps.term.tuis.mpv;
in
{
  options.apps.term.tuis.mpv = with types; {
    enable = mkBoolOpt false "Enable MPV";
  };
  config = mkIf cfg.enable {
    xdg.configFile."mpv/mpv.conf".text = ''
      osc = yes
      keepaspect = yes
      osd-level = 1
      osd-font = 'Iosevka Slab Term'
      osd-font-size = 14
      osd-color = '${colors.mauve.hex}'
      osd-border-color = '${colors.surface1.hex}'
      osd-shadow-color = '${colors.mantle.hex}'
      osd-bar-align-y = 0.95
      keep-open = yes
      idle = yes
      hwdec = auto
      vo = gpu
      volume = 100
    '';
    home.packages = with pkgs; [
      mpv
    ];
  };
}
