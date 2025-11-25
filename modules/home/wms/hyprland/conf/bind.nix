{
  lib,
  pkgs,
  inputs,
  mod,
  ...
}: let
  modshift = "${mod}SHIFT";
  workspaces = builtins.concatLists (builtins.genList (
      x: let
        ws = let
          c = (x + 1) / 10;
        in
          builtins.toString (x + 1 - (c * 10));
      in [
        "${mod}, ${ws}, workspace, ${toString (x + 1)}"
        "${modshift}, ${ws}, movetoworkspace, ${toString (x + 1)}"
      ]
    )
    10);
in
  [
    ''${mod},R,exec,${lib.getExe pkgs.ghostty}''
    ''${mod},Z,exec,${lib.getExe inputs.zen-browser.packages.${pkgs.system}.beta}''

    "${mod},D,exec,fuzzel"
    "${mod},Q,killactive"
    "${mod},M,exit"
    "${mod},P,pseudo"

    "${mod},J,togglesplit,"

    "${mod},T,togglegroup," # group focused window
    "${modshift},G,changegroupactive," # switch within the active group
    "${mod},V,togglefloating," # toggle floating for the focused window
    "${mod},F,fullscreen," # fullscreen focused window

    # workspace controls
    "${modshift},right,movetoworkspace,+1" # move focused window to the next ws
    "${modshift},left,movetoworkspace,-1" # move focused window to the previous ws
    "${mod},mouse_down,workspace,e+1" # move to the next ws
    "${mod},mouse_up,workspace,e-1" # move to the previous ws
    "${modshift},O,exec,wl-ocr"
    "${mod},S,exec,${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp})\" - | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png"

    "${mod},Period,exec, tofi-emoji"

    "${modshift},L,exec,swaylock --grace 0" # lock screen
  ]
  ++ workspaces
