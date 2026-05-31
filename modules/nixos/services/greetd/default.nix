{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.greetd;

  # Build the color theme string from the attrset
  themeString = builtins.concatStringsSep ";" (
    lib.mapAttrsToList (name: value: "${name}=${value}") cfg.theme
  );

in

{
  options.greetd = with types; {

    enable = mkBoolOpt false ''
      Enable greetd display manager with tuigreet (TUI login prompt).
      Replaces GDM as your login screen. No GNOME dependencies.
    '';

    session = mkOption {
      type = types.str;
      default = "${pkgs.niri-unstable}/bin/niri-session";
      example = "${pkgs.hyprland}/bin/Hyprland";
      description = ''
        The session command to launch after successful login.
        This is what starts your desktop/WM. Defaults to niri-session
        since that's what you use.
      '';
    };

    greeting = mkOption {
      type = types.str;
      default = "Welcome back, Taylor";
      example = "Who TF Are You?";
      description = ''
        Text shown above the login prompt. Change this to whatever
        you want to see when you boot up.
      '';
    };

    showTime = mkOption {
      type = types.bool;
      default = true;
      description = "Show the current date and time above the prompt.";
    };

    timeFormat = mkOption {
      type = types.str;
      default = "%a, %b %d • %H:%M";
      example = "%I:%M %p | %a • %h | %F";
      description = ''
        strftime format string for the time display.
        Common placeholders:
          %a  = abbreviated weekday (Sun, Mon)
          %b  = abbreviated month (Jan, Feb)
          %d  = day of month (01-31)
          %H  = hour (00-23)
          %M  = minute (00-59)
          %I  = hour (01-12)
          %p  = AM/PM
          %F  = full date (2026-05-31)
          %r  = 12-hour time (11:45:30 PM)
      '';
    };

    asterisks = mkOption {
      type = types.bool;
      default = true;
      description = "Show asterisks (`***`) while typing your password.";
    };

    rememberUser = mkOption {
      type = types.bool;
      default = true;
      description = "Pre-fill the last logged-in username so you don't retype it.";
    };

    windowPadding = mkOption {
      type = types.int;
      default = 2;
      description = "Empty space between the terminal edge and the prompt box.";
    };

    containerPadding = mkOption {
      type = types.int;
      default = 2;
      description = "Empty space INSIDE the prompt box around the text fields.";
    };

    theme = mkOption {
      type = types.attrsOf types.str;
      default = {
        border    = "magenta";   # The box outline around the prompt
        container = "black";     # Background fill inside the box
        text      = "cyan";      # General text color
        time      = "yellow";    # Date/time display
        prompt    = "green";     # "Username:" / "Password:" labels
        input     = "white";     # What you type
        action    = "blue";      # Bottom action bar ("F2: Command...")
        button    = "yellow";    # Keybinding hints inside the action bar
      };
      description = ''
        ANSI color theme for tuigreet. Each key maps to a UI element.
        Uses the Linux VT's 16 ANSI color names:

        Available colors: black, red, green, yellow, blue,
        magenta, cyan, white, gray, dark_gray, light_* variants.

        Keys you can set:
          border    → the box outline
          container → background inside the box
          text      → base text
          time      → date/time
          prompt    → "Username:" / "Password:" labels
          input     → typed text color
          action    → bottom bar text
          button    → keybinding hints (F2, F3, F12)
      '';
      example = {
        border    = "magenta";
        container = "black";
        text      = "cyan";
        time      = "yellow";
        prompt    = "green";
        input     = "white";
        action    = "blue";
        button    = "yellow";
      };
    };

  };

  config = mkIf cfg.enable {

    # ── Disable GDM (the broken greeter) ──────────────────────────
    services.xserver.displayManager.gdm.enable = false;

    # ── Enable greetd + tuigreet ───────────────────────────────────
    services.greetd = {
      enable = true;

      settings = {
        default_session = {
          command = builtins.concatStringsSep " " [
            "${pkgs.greetd.tuigreet}/bin/tuigreet"
            "--greeting '${cfg.greeting}'"
            (lib.optionalString cfg.showTime "--time --time-format '${cfg.timeFormat}'")
            (lib.optionalString cfg.asterisks "--asterisks")
            (lib.optionalString cfg.rememberUser "--remember")
            "--window-padding ${toString cfg.windowPadding}"
            "--container-padding ${toString cfg.containerPadding}"
            "--theme '${themeString}'"
            "--cmd ${cfg.session}"
          ];
          user = "greeter";
        };
      };
    };

    # ── Prevent kernel boot logs from flooding the TTY ────────────
    # Without this, systemd messages will overwrite your greeter
    # screen and you'll see a mess of text instead of the login prompt.
    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal";
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };

    # ── Ensure tuigreet's cache dir exists ────────────────────────
    # Needed for --remember to persist across reboots.
    systemd.tmpfiles.rules = [
      "d /var/cache/tuigreet 0755 greeter greeter -"
    ];

  };

}
