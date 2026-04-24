{
  config,
  lib,
  ...
}:
with lib;
with lib.custom;
let
  cfg = config.apps.tools.dms;
in
{
  options.apps.tools.dms = with types; {
    enable = mkBoolOpt false "Enable DMS (DankMaterialShell)";

    # Transparency settings (0.0 = transparent, 1.0 = opaque)
    # Bar: very transparent (70% opaque), widget menus: nearly opaque (95% opaque)
    barTransparency = mkOpt 0.7 "Bar background transparency";
    notepadTransparency = mkOpt 0.9 "Notepad transparency";
    widgetMenuTransparency = mkOpt 0.95 "Widget/menu transparency";

    # Custom theme overrides (optional)
    # Override specific colors without changing your GTK theme
    customTheme = mkOption {
      type = with types; nullOr (attrsOf str);
      default = null;
      description = "Override theme colors. Example: { primary = \"#7c3aed\"; surfaceText = \"#e0e0e0\"; }";
    };
  };

  config = mkIf cfg.enable {
    programs.dank-material-shell = {
      enable = true;
      systemd.enable = true;
      enableVPN = true;
      enableCalendarEvents = true;
      enableDynamicTheming = true;
      enableSystemMonitoring = true;
      enableAudioWavelength = true;

      settings = {
        # Fonts - using Iosevka typespace
        fontFamily = "Iosevka";
        monoFontFamily = "Iosevka";
        fontWeight = 400;
        fontScale = 1.0;

        # Core settings
        currentThemeName = "purple";
        cornerRadius = 16;
        use24HourClock = true;
        firstDayOfWeek = -1;

        # Bar widgets
        showLauncherButton = true;
        showWorkspaceSwitcher = true;
        showFocusedWindow = true;
        showWeather = true;
        showMusic = true;
        showClipboard = true;
        showCpuUsage = true;
        showMemUsage = true;
        showCpuTemp = true;
        showGpuTemp = true;
        showSystemTray = true;
        showClock = true;
        showNotificationButton = true;
        showBattery = true;
        showControlCenterButton = true;

        # Control center
        controlCenterShowNetworkIcon = true;
        controlCenterShowBluetoothIcon = true;
        controlCenterShowAudioIcon = true;
        controlCenterShowVpnIcon = true;

        # Workspaces
        workspaceDragReorder = true;
        waveProgressEnabled = true;
        runningAppsCompactMode = true;

        # Launcher
        appLauncherViewMode = "list";
        spotlightModalViewMode = "list";

        # Theming
        animationSpeed = 1;
        m3ElevationEnabled = true;

        # Power
        fadeToLockEnabled = true;
        loginctlLockIntegration = true;

        # OSD
        osdVolumeEnabled = true;
        osdBrightnessEnabled = true;
        osdMicMuteEnabled = true;
        osdCapsLockEnabled = true;
      };
    };
  };
}

