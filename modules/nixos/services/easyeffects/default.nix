{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.services.easyeffects;
  jsonFormat = pkgs.formats.json { };
in

{
  options.services.easyeffects = with types; {
    enable = mkBoolOpt false "Enable EasyEffects audio processing";
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.easyeffects ];

    # Use home-manager to place preset files in the user's XDG data dir.
    home-manager.users.helios = {
      xdg.dataFile = {
        "easyeffects/input/helios-mic.json" = {
          source = jsonFormat.generate "easyeffects-input-helios-mic.json" {
            input = {
              blocklist = [ ];

plugins_order = [
                "rnnoise#0"
                "compressor#0"
                "gate#0"
                "limiter#0"
              ];

              "rnnoise#0" = {
                bypass = false;
                "enable-vad" = false;
                "input-gain" = 0.0;
                "model-name" = "\"\"";
                "output-gain" = 0.0;
                release = 20.0;
                "use-standard-model" = true;
                "vad-thres" = 30.0;
                wet = 0.0;
              };

              "compressor#0" = {
                attack = 15.0;
                bypass = false;
                dry = -80.01;
                "hpf-frequency" = 10.0;
                "hpf-mode" = "Off";
                "input-gain" = 0.0;
                knee = -6.0;
                "lpf-frequency" = 20000.0;
                "lpf-mode" = "Off";
                makeup = 3.0;
                mode = "Downward";
                "output-gain" = 0.0;
                ratio = 4.0;
                release = 200.0;
                "release-threshold" = -40.0;
                sidechain = {
                  lookahead = 0.0;
                  mode = "RMS";
                  preamp = 0.0;
                  reactivity = 10.0;
                  source = "Middle";
                  "stereo-split-source" = "Left/Right";
                  type = "Feed-forward";
                };
                "stereo-split" = false;
                threshold = -18.0;
                wet = 0.0;
              };

"gate#0" = {
              attack = 5.0;
              bypass = false;
              "curve-threshold" = -40.0;
              "curve-zone" = -2.0;
              dry = -80.01;
              "hpf-frequency" = 10.0;
              "hpf-mode" = "Off";
              hysteresis = true;
              "hysteresis-threshold" = -3.0;
              "hysteresis-zone" = -1.0;
              "input-gain" = 0.0;
              "lpf-frequency" = 20000.0;
              "lpf-mode" = "Off";
              makeup = 1.0;
              "output-gain" = 0.0;
              reduction = -12.0;
              release = 250.0;
                sidechain = {
                  lookahead = 0.0;
                  mode = "RMS";
                  preamp = 0.0;
                  reactivity = 10.0;
                  source = "Middle";
                  "stereo-split-source" = "Left/Right";
                  type = "Internal";
                };
                "stereo-split" = false;
                wet = -1.0;
              };

              "limiter#0" = {
                alr = false;
                "alr-attack" = 5.0;
                "alr-knee" = 0.0;
                "alr-release" = 50.0;
                attack = 2.0;
                bypass = false;
                dithering = "16bit";
                "gain-boost" = false;
                "input-gain" = 0.0;
                lookahead = 2.0;
                mode = "Herm Wide";
                "output-gain" = 0.0;
                oversampling = "None";
                release = 5.0;
                "sidechain-preamp" = 0.0;
                "sidechain-type" = "Internal";
                "stereo-link" = 100.0;
                threshold = -1.5;
              };
            };
          };
        };

        "easyeffects/autoload/input/alsa_input.usb-HP__Inc_HyperX_SoloCast_2_1H55410MMH-00.analog-stereo:Analog_Stereo_Input.json" = {
          source = jsonFormat.generate "easyeffects-autoload-solo-cast-2.json" {
            device = "alsa_input.usb-HP__Inc_HyperX_SoloCast_2_1H55410MMH-00.analog-stereo";
            "device-description" = "HyperX SoloCast 2";
            "device-profile" = "Analog Stereo Input";
            "preset-name" = "helios-mic";
          };
        };
      };
    };
  };
}