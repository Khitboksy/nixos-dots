{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.ui.greetd;
  system = pkgs.stdenv.hostPlatform.system;

  sessionBin = "${inputs.niri-src.packages.${system}.niri}/bin/niri-session";
  greeterBin = "${pkgs.tuigreet}/bin/tuigreet";

  command = pkgs.writeShellScript "greetd-session" ''
    exec ${greeterBin} \
      --cmd '${sessionBin}'
  '';
in

{
  options.ui.greetd = with types; {
    enable = mkBoolOpt false "Enable greetd + tuigreet TUI login manager";
  };

  config = mkIf cfg.enable {

    # ── Disable GDM ──────────────────────────────────────────
    services.displayManager.gdm.enable = lib.mkForce false;

    # ── Enable greetd + tuigreet ─────────────────────────────
    services.greetd = {
      enable = true;

      settings = {
        default_session = {
          inherit command;
          user = "greeter";
        };
      };
    };

    # ── Text greeter mode ────────────────────────────────────
    services.greetd.useTextGreeter = true;

  };
}
