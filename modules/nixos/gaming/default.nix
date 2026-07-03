{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.gaming;
in

{

  options.gaming = with types; {
    enable = mkBoolOpt false "Enable Gaming Module";
  };

  config = mkIf cfg.enable {

    gaming = {
      apps.steam.enable = true;
    };
    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [
      (lutris.override {
        extraLibraries = pkgs: [
          qt5.qtwayland
          wayland
        ];
      })

      protonup-qt
      r2modman
      clonehero
      ckan
    ];

    boot.kernelParams = [
      "preempt=full"
      "threadirqs"
      "skew-tick=1"
      "cpufreq.default_governor=performance"
    ];
  };
}
