{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.custom; let
  cfg = config.shells.notification-urgent;
in {
  options.shells.notification-urgent = with types; {
    enable = mkBoolOpt false "Enable Notification & Urgent helper";

    # Icon shown in DMS notification (default: checkmark)
    icon = mkOpt types.str "checkbox-marked" "Default notification icon";

    # Timeout for DMS notifications in ms
    timeout = mkOpt types.int 3000 "Notification timeout (ms)";

    # Urgent timeout (longer for hanging agents)
    urgentTimeout = mkOpt types.int 8000 "Urgent notification timeout (ms)";

    # Context warning threshold (百分比)
    contextThreshold = mkOpt types.int 80 "Context warning threshold (%)";
  };

  config = mkIf cfg.enable {
    programs.fish = {
      interactiveShellInit = ''
        # === Helper Functions ===

        # Check if opencode or related app is focused
        function __nu_is_opencode_focused
          if test -z "$DISPLAY" -a -z "$WAYLAND_DISPLAY"
            return 1
          end
          # Try dms first (works on wayland)
          if type -q dms
            set -l active_app (dms ipc call windowManager getActiveApp 2>/dev/null)
            if test "$active_app" = "opencode" -o "$active_app" = "opencode.ai"
              return 0
            end
          end
          # Fallback to xdotool for X11
          if type -q xdotool
            set -l classname (xdotool getactivewindow getwindowclassname 2>/dev/null)
            if test "$classname" = "opencode" -o "$classname" = "OpenCode"
              return 0
            end
          end
          return 1
        end

        # Send notification (skips if opencode focused)
        function __nu_notify
          set -l summary $argv[1]
          set -l body $argv[2]
          set -l timeout_ms $argv[3]
          set -l icon $argv[4]

          # Skip if opencode is focused
          if __nu_is_opencode_focused
            return
          end

          # Use defaults
          if test -z "$timeout_ms"
            set timeout_ms 3000
          end
          if test -z "$icon"
            set icon checkmark
          end

          dms notify "$summary" "$body" --timeout $timeout_ms --icon $icon &
        end

        # === Main Notification Functions ===

        # agentTodo: Silent notification when agent finishes TODO item
        # Usage: agentTodo "mini" "Finished analyzing files"
        function agent-todo
          set -l agent $argv[1]
          set -l item $argv[2]
          __nu_notify "$agent finished" "$item" 2000 "checkbox-marked"
        end

        # agentHang: Urgent notification when agent hangs (red text scenario)
        # Usage: agentHang "gpt-4" "Daily token limit reached"
        function agent-hang
          set -l agent $argv[1]
          set -l reason $argv[2]

          # Skip if opencode is focused
          if __nu_is_opencode_focused
            return
          end

          # Send urgent notification with action (using notify-send for actions)
          if type -q notify-send
            notify-send -u critical -A "stop=Kill Agent" -A "wait=Wait" \
              "$agent hanging" "$reason" &
          else
            # Fallback to DMS
            dms notify "$agent hanging" "$reason" --timeout 8000 --icon alert &
          end

          # Also bell for urgency
          printf "\a"
        end

        # agentStopped: Notification when agent stops abruptly before finishing
        # Usage: agent-stopped "mini" "Connection lost"
        function agent-stopped
          set -l agent $argv[1]
          set -l reason $argv[2]

          __nu_notify "$agent stopped" "$reason" 5000 "alert-circle" &
          printf "\a"
        end

        # mcpStatus: Notification when MCP server status changes
        # Usage: mcpStatus "opencode" "connected" or "mcpStatus" "opencode" "disconnected"
        function mcp-status
          set -l server $argv[1]
          set -l status $argv[2]

          set -l icon "server"
          set -l summary "$server"

          if test "$status" = "connected"
            set summary "$server connected"
            set icon "server-network"
          else if test "$status" = "disconnected"
            set summary "$server disconnected"
            set icon "server-network-off"
          else if test "$status" = "error"
            set summary "$server error"
            set icon "alert-circle"
          end

          __nu_notify "$summary" "MCP server status changed" 3000 "$icon" &
        end

        # context-warn: Notification at 80% context threshold
        # Usage: context-warn "o1" 85
        function context-warn
          set -l session $argv[1]
          set -l pct $argv[2]

          if test -z "$pct"
            set pct 80
          end

          # Skip if opencode is focused
          if __nu_is_opencode_focused
            return
          end

          # Use fixed message (avoid variable interpolation issues with Nix)
          dms notify "$session context" "at 80%" 4000 "brain" &
          printf "\a"
        end

        # Legacy: notify-done (kept for backwards compatibility)
        function notify-done
          set -l summary $argv[1]
          set -l body ""
          if test (count $argv) -gt 1
            set body $argv[2]
          end

          # Skip if opencode is focused
          if __nu_is_opencode_focused
            return
          end

          dms notify "$summary" "$body" --timeout 3000 --icon checkmark &
          printf "\a"
        end

        # Aliases
        alias done notify-done
        alias agent-todo agent-todo
        alias agent-hang agent-hang
        alias agent-stopped agent-stopped
        alias mcp-status mcp-status
        alias context-warn context-warn
      '';
    };
  };
}
