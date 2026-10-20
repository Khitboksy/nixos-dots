{
  lib,
  appimageTools,
  fetchurl,
}:

let

  pname = "burrow";
  # This is the "shell" version shipped by the AppImage (Electron 11 + Pepper
  # Flash + boot.js). The app layer updates itself (see note below), so this
  # only needs bumping when upstream raises the shell (latest.json `shell` > 1).
  version = "1.3.0";

  # Upstream only publishes prebuilt binaries (no GitHub releases).
  # The download path is stable; the `?v=` cache-buster is not (it rotates and
  # goes stale), so we pin the stable path and verify by hash instead.
  # sha256 taken from https://burrow.moe/download/SHA256SUMS
  src = fetchurl {
    name = "${pname}-${version}.AppImage";
    url = "https://burrow.moe/download/Burrow-x86_64.AppImage";
    sha256 = "45289850b53f70b5a27e6999e0f47bc9aed5808f3162487ace5041afbb9bb945";
  };

  # Extracted AppDir; reused by wrapType2 and for the desktop entry/icon below.
  appimageContents = appimageTools.extract {
    inherit pname version src;
  };

  # Updating (only needed when upstream raises the shell version):
  #   1. sha256: https://burrow.moe/download/SHA256SUMS (or nix-prefetch-url).
  #   2. version: the AppImage's own resources/app/package.json.
  # App-layer updates (e.g. 1.3.0 -> 1.3.1) need no change here: the client
  # downloads signed bundles into ~/.config/AJ Private Client/updates and
  # boot.js runs the newest staged copy. That dir is writable, so the
  # read-only /nix/store does not block self-updates.

in
appimageTools.wrapType2 {
  inherit pname version src;

  # Electron 11 (Chromium 87) has no Wayland support and must run on XWayland.
  # The host sets GDK_BACKEND=wayland globally, which makes the app abort with
  # "Gtk-WARNING: cannot open display: :0". Force the X11 backend for this app.
  # (wrapType2 has no extraArgs; extraBwrapArgs is forwarded to buildFHSEnv.)
  extraBwrapArgs = [
    "--setenv"
    "GDK_BACKEND"
    "x11"
  ];

  # Ship the AppImage's own desktop entry + icon so the client appears in
  # application launchers and runs detached (no terminal). wrapType2 does not
  # install these on its own. Exec must point at our wrapper, not AppRun.
  extraInstallCommands = ''
    install -Dm644 ${appimageContents}/burrow.desktop $out/share/applications/burrow.desktop
    sed -i 's#^Exec=AppRun --no-sandbox %U#Exec=${pname} %U#' $out/share/applications/burrow.desktop
    chmod 444 $out/share/applications/burrow.desktop

    # The AppImage ships the icon in an unadvertised hicolor/300x300 dir, which
    # icon lookup ignores (hicolor's index.theme lists 16..512 only). Re-home it
    # into 256x256 so the Icon=burrow name actually resolves in GTK/rofi.
    install -Dm444 ${appimageContents}/usr/share/icons/hicolor/300x300/apps/burrow.png \
      $out/share/icons/hicolor/256x256/apps/burrow.png
  '';

  meta = {
    description = "Client for the Burrow (Animal Jam Classic private server)";
    homepage = "https://burrow.moe";
    # Electron 11 + bundled Pepper Flash; upstream is "UNLICENSED"
    license = lib.licenses.unfree;
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
  };
}
