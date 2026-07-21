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
  cfg = config.shared.ui.greetd;
  system = pkgs.stdenv.hostPlatform.system;

  greeterBin = "${getExe pkgs.tuigreet}";

  theme = "action=grey;border=magenta;button=yellow;input=white;prompt=green;text=cyan;time=yellow";

  niriSession = "${getExe' inputs.niri-src.packages.${system}.niri "niri-session"}";

  command = pkgs.writeShellScript "greetd-session" ''
    exec ${greeterBin} \
      --greeting "Welcome back, Taylor" \
      --time \
      --time-format '%a, %b %d • %H:%M' \
      --asterisks \
      --remember \
      --window-padding 2 \
      --container-padding 2 \
      --theme '${theme}' \
      --cmd '${niriSession}'
  '';
in

{
  options.shared.ui.greetd = with types; {
    enable = mkBoolOpt false "Enable greetd + tuigreet TUI login manager";
  };

  config = mkIf cfg.enable {

    services.displayManager.gdm.enable = lib.mkForce false;

    services.greetd = {
      enable = true;

      settings = {
        default_session = {
          inherit command;
          user = "greeter";
        };
      };
    };

    services.greetd.useTextGreeter = true;

  };
}
