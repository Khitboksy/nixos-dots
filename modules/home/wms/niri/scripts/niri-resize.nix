{ pkgs, ... }:
{
  niri-resize-float = pkgs.writeShellScriptBin "niri-resize-float" ''
    # niri-resize-float - Resize floating windows with auto-centering
    set -euo pipefail

    ACTION="''${1:-help}"
    STEP="''${2:-}"

    PROPORTIONAL_STEP="''${STEP:-5}"
    AXIS_STEP="''${STEP:-10}"

    case "$ACTION" in
      grow)
        niri msg action set-window-width "+''${PROPORTIONAL_STEP}%"
        niri msg action set-window-height "+''${PROPORTIONAL_STEP}%"
        ;;
      shrink)
        niri msg action set-window-width "-''${PROPORTIONAL_STEP}%"
        niri msg action set-window-height "-''${PROPORTIONAL_STEP}%"
        ;;
      wider)
        niri msg action set-window-width "+''${AXIS_STEP}%"
        ;;
      narrower)
        niri msg action set-window-width "-''${AXIS_STEP}%"
        ;;
      taller)
        niri msg action set-window-height "+''${AXIS_STEP}%"
        ;;
      shorter)
        niri msg action set-window-height "-''${AXIS_STEP}%"
        ;;
      center)
        niri msg action center-window
        ;;
      preset)
        case "''${2:-medium}" in
          s|small)
            niri msg action set-window-width "30%"
            niri msg action set-window-height "30%"
            ;;
          m|medium)
            niri msg action set-window-width "50%"
            niri msg action set-window-height "50%"
            ;;
          l|large)
            niri msg action set-window-width "75%"
            niri msg action set-window-height "75%"
            ;;
          *)
            echo "Unknown preset: $2 (use: small, medium, large)"
            exit 1
            ;;
        esac
        ;;
      *)
        echo "Usage: niri-resize-float <action> [step%]"
        echo ""
        echo "Actions:"
        echo "  grow           Grow proportionally (+5% width & height)"
        echo "  shrink         Shrink proportionally (-5% width & height)"
        echo "  wider          Widen (+10% width)"
        echo "  narrower       Narrow (-10% width)"
        echo "  taller         Taller (+10% height)"
        echo "  shorter        Shorter (-10% height)"
        echo "  center         Center the window"
        echo "  preset <name>  Snap to preset (small=30%, medium=50%, large=75%)"
        exit 1
        ;;
    esac

    if [[ "$ACTION" != "center" ]]; then
      niri msg action center-window
    fi
  '';
}
