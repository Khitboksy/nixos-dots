{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.custom;
let
  cfg = config.services.t3code;
  system = pkgs.stdenv.hostPlatform.system;

  versions = {
    stable = {
      tag = "v0.0.23";
      name = "T3-Code-0.0.23-x86_64.AppImage";
      url = "https://github.com/pingdotgg/t3code/releases/download/v0.0.23/T3-Code-0.0.23-x86_64.AppImage";
      hash = "sha256-qMPSxQuiCwLT0As1foSDqaKoNMoLrjbKbDSwQW56T7g=";
    };
    latest = {
      tag = "v0.0.24-nightly.20260514.285";
      name = "T3-Code-0.0.24-nightly.20260514.285-x86_64.AppImage";
      url = "https://github.com/pingdotgg/t3code/releases/download/v0.0.24-nightly.20260514.285/T3-Code-0.0.24-nightly.20260514.285-x86_64.AppImage";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
  };

  selected = versions.${cfg.version};

  t3code = pkgs.stdenv.mkDerivation {
    pname = "t3code-${cfg.version}";
    version = selected.tag;

    src = pkgs.fetchurl {
      url = selected.url;
      sha256 = selected.hash;
    };

    dontBuild = true;
    dontConfigure = true;
    dontPatchShebangs = true;

    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/${cfg.binary}
      chmod +x $out/bin/${cfg.binary}
    '';

    meta = with lib; {
      description = "T3 Code - A harness for coding agents";
      homepage = "https://t3.codes";
      license = licenses.mit;
      maintainers = [ ];
      platforms = [ "x86_64-linux" ];
    };
  };
in

{
  options.services.t3code = with types; {
    enable = mkBoolOpt false "Enable T3 Code desktop application";
    version = mkOption {
      type = types.enum [ "stable" "latest" ];
      default = "stable";
      description = "T3 Code version to install";
    };
    binary = mkOption {
      type = types.enum [ "t3code" "t3code-nightly" ];
      default = "t3code";
      description = "Binary name to install";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ t3code ];

    xdg.desktopEntries.${cfg.binary} = {
      name = "T3 Code";
      genericName = "AI Coding Agent Harness";
      comment = "A minimal web GUI for coding agents";
      exec = "${t3code}/bin/${cfg.binary} %U";
      terminal = false;
      categories = [ "Development" "IDE" ];
      startupNotify = true;
    };
  };
}