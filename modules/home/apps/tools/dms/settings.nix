colors:
{
  # Fonts - using Iosevka typespace
  fontFamily = "Iosevka";
  monoFontFamily = "Iosevka";
  fontWeight = 600;
  fontScale = 1.0;
  currentThemeName = "purple";

  # Core settings
  cornerRadius = 12;
  use24HourClock = true;
  firstDayOfWeek = -1;

  # Bar widgets
  showLauncherButton = false;
  showWorkspaceSwitcher = true;
  showFocusedWindow = true;
  showWeather = true;
  showMusic = true;
  showClipboard = true;
  showCpuUsage = true;
  showMemUsage = true;
  showCpuTemp = true;
  showGpuTemp = false;
  showSystemTray = true;
  showClock = true;
  showNotificationButton = true;
  showBattery = false;
  showControlCenterButton = true;

  # Control center
  controlCenterShowNetworkIcon = false;
  controlCenterShowBluetoothIcon = false;
  controlCenterShowAudioIcon = false;
  controlCenterShowVpnIcon = true;

  # Workspaces
  workspaceDragReorder = false;
  waveProgressEnabled = true;
  runningAppsCompactMode = true;

  # Theming
  animationSpeed = 1;
  m3ElevationEnabled = true;

  # Power
  fadeToLockEnabled = false;
  loginctlLockIntegration = true;

  # OSD
  osdVolumeEnabled = true;
  osdBrightnessEnabled = false;
  osdMicMuteEnabled = false;
  osdCapsLockEnabled = false;

  barConfigs = [
    {
      id = "default";
      name = "Main Bar";
      enabled = true;
      position = 0;
      screenPreferences = [
        "all"
      ];
      showOnLastDisplay = true;
      leftWidgets = [
        {
          id = "workspaceSwitcher";
          enabled = true;
        }
        {
          id = "focusedWindow";
          enabled = true;
        }
      ];
      centerWidgets = [
        {
          id = "cpuUsage";
          enabled = true;
        }
        {
          id = "clock";
          enabled = true;
        }
        {
          id = "weather";
          enabled = true;
        }
        {
          id = "memUsage";
          enabled = true;
        }
      ];
      rightWidgets = [
        {
          id = "music";
          enabled = true;
        }
        {
          id = "systemTray";
          enabled = true;
        }
        {
          id = "clipboard";
          enabled = true;
        }
        {
          id = "notificationButton";
          enabled = true;
        }
        {
          id = "controlCenterButton";
          enabled = true;
        }
      ];
      spacing = 5;
      innerPadding = 5;
      bottomGap = 0;
      transparency = 0.8;
      widgetTransparency = 0.75;
      squareCorners = false;
      noBackground = false;
      gothCornersEnabled = false;
      gothCornerRadiusOverride = false;
      gothCornerRadiusValue = 12;
      borderEnabled = false;
      borderColor = "surfaceText";
      borderOpacity = 1;
      borderThickness = 1;
      widgetOutlineEnabled = false;
      widgetOutlineColor = "primary";
      widgetOutlineOpacity = 1;
      widgetOutlineThickness = 1;
      fontScale = 0.95;
      autoHide = false;
      autoHideDelay = 250;
      showOnWindowsOpen = false;
      openOnOverview = false;
      visible = true;
      popupGapsAuto = true;
      popupGapsManual = 4;
      maximizeDetection = true;
      scrollEnabled = true;
      scrollXBehavior = "column";
      scrollYBehavior = "workspace";
      shadowIntensity = 0;
      shadowOpacity = 10;
      shadowColorMode = "text";
      shadowCustomColor = "#000000";
      clickThrough = false;
    }
  ];
}
