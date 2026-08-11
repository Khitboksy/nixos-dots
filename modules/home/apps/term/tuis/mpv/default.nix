{
  config,
  pkgs,
  lib,
  zenith,
  ...
}:
with zenith.lib';
let
  cfg = config.apps.term.tuis.mpv;
in
{
  options.apps.term.tuis.mpv = with lib.types; {
    enable = mkBoolOpt false "Enable MPV";
  };
  config = lib.mkIf cfg.enable {
    xdg.configFile."mpv/mpv.conf".text = ''
      osc = yes
      keepaspect = yes
      osd-level = 1
      osd-font = 'Iosevka Slab Term'
      osd-font-size = 14
      osd-color = '${colors.helios.mauve.hex}'
      osd-border-color = '${colors.helios.surface1.hex}'
      osd-shadow-color = '${colors.helios.mantle.hex}'
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
