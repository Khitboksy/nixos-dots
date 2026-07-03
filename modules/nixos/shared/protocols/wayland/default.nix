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
  cfg = config.shared.protocols.wayland;
  system = pkgs.stdenv.hostPlatform.system;
in
{
  options.shared.protocols.wayland = with types; {
    enable = mkBoolOpt false "Enable Wayland Protocol";
  };

  config = mkIf cfg.enable {
    services.displayManager.gdm.enable = true;

    programs = {
      uwsm.enable = true;
      niri = {
        enable = true;
        withUWSM = true;
        package = inputs.niri-src.packages.${system}.niri;
      };
    };
    environment = {
      variables = {
        NIXOS_OZONE_WL = "1";
        # __GL_GSYNC_ALLOWED = "0";
        # __GL_VRR_ALLOWED = "0";
        _JAVA_AWT_WM_NONEREPARENTING = "1";
        # SSH agent is handled by gpg-agent (home-manager) — see
        # services.gpg-agent.enableSshSupport = true in home config.
        # Setting this here would conflict with gpg-agent's socket.
        # SSH_AUTH_SOCK = "...";  # ← not needed, gpg-agent manages it
        DISABLE_QT5_COMPAT = "0";
        GDK_BACKEND = "wayland";
        ANKI_WAYLAND = "1";
        QT_AUTO_SCREEN_SCALE_FACTOR = "1";
        QT_QPA_PLATFORM = "wayland";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        QT_QPA_PLATFORMTHEME = "gtk3";
        DISABLE_QT_COMPAT = "0";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        MOZ_ENABLE_WAYLAND = "1";
        WLR_BACKEND = "wayland";
        WLR_RENDERER = "wayland";
        XDG_SESSION_TYPE = "wayland";
        SDL_VIDEODRIVER = "wayland,x11";
        XDG_CACHE_HOME = "/home/helios/.cache";
        CLUTTER_BACKEND = "wayland";
      };
      # SSH agent is managed by gpg-agent (home-manager's
      # services.gpg-agent.enableSshSupport = true).  No need for
      # gnome-keyring-daemon or a separate ssh-agent here.
      loginShellInit = ''
        dbus-update-activation-environment --systemd DISPLAY
      '';
    };

    services.pulseaudio.support32Bit = true;

    xdg.portal = {
      enable = true;
      #wlr.enable = false;
      #config.common.default = "*";
      extraPortals = [
        #pkgs.xdg-desktop-portal-gtk
        #pkgs.xdg-desktop-portal-gnome
      ];
    };
  };
}
