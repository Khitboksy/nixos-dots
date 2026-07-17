{
  inputs,
  channels,
  lib,
  ...
}:
final: prev: {
  vesktop =
    (prev.vesktop.override {
      electron_40 = final.electron;
    }).overrideAttrs
      (old: {
        preBuild = ''
          # electron builds must be writable
          cp -r ${final.electron.dist} electron-dist
          chmod -R u+w electron-dist
        '';
      });
}
