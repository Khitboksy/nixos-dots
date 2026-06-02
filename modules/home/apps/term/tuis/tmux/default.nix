{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.apps.term.tuis.tmux;
in

{

  options.apps.term.tuis.tmux = with types; {
    enable = mkBoolOpt false "Enable Tmux";
  };

  config = mkIf cfg.enable {

    programs.tmux = {

      enable = true;
      shell = "${getExe pkgs.fish}";
      historyLimit = 100000;
      plugins = with pkgs.tmuxPlugins; [
        sensible
        vim-tmux-navigator
        yank
        cpu
        {
          plugin = catppuccin;
          extraConfig = ''
            set -g @catppuccin_flavour 'mocha'
            set -g @catppuccin_window_status_style "basic"
            set -g @catppuccin_status_modules "application session uptime"
          '';
        }
        {
          plugin = resurrect;
          extraConfig = ''
            set -g @resurrect-strategy-vim 'session'
            set -g @resurrect-strategy-nvim 'session'
            set -g @resurrect-capture-pane-contents 'on'
            resurrect_dir="$XDG_CACHE_HOME/.tmux/resurrect"
            set -g @resurrect-dir $resurrect_dir
            set -g @resurrect-hook-post-save-all 'target=$(readlink -f $resurrect_dir/last); sed "s| --cmd .*-vim-pack-dir||g; s|/etc/profiles/per-user/$USER/bin/||g; s|/home/$USER/.nix-profile/bin/||g" $target | sponge $target'
          '';
        }
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-boot 'on'
            set -g @continuum-save-interval '10'
            set -g @continuum-systemd-start-cmd 'start-server'
          '';
        }
      ];
      extraConfig = ''
        set-option -sa terminal-overrides ",xterm*:Tc"
        set -g mouse on

        set -g base-index 1
        set -g pane-base-index 1
        setw -g mode-keys vi
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on

        set -g default-terminal "$TERM"
        set -ag terminal-overrides ",$TERM:Tc"
        set -g allow-passthrough on

        # Vim-style copy mode bindings
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

        # Split panes
        bind '"' split-window -v -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"

        # Prefix setup
        unbind C-b
        set -g prefix C-Space
        bind C-Space send-prefix

        # Alt+arrows to switch panes
        bind -n M-H previous-window
        bind -n M-L next-window

        # Catppuccin status bar via plugin format variables
        set -g status-right-length 100
        set -g status-left-length 100
        set -g status-left ""
        set -g status-right "#{E:@catppuccin_status_application}"
        set -ag status-right "#{E:@catppuccin_status_session}"
        set -ag status-right "#{E:@catppuccin_status_uptime}"

        set-hook -g after-new-session 'run-shell "tmux rename-session \"#{b:pane_current_path}\""'
        set-hook -g after-new-window 'run-shell "tmux rename-session \"#{b:pane_current_path}\""'
        set-hook -g after-kill-pane 'run-shell "tmux rename-session \"#{b:pane_current_path}\""'
        set-hook -g pane-focus-in 'run-shell "tmux rename-session \"#{b:pane_current_path}\""'
      '';
    };

    systemd.user.services.tmux = {
      Unit = {
        Description = "tmux default session (detached)";
        Documentation = "man:tmux(1)";
      };

      Service = {
        Type = "forking";
        Environment = "DISPLAY=:0";
        ExecStart = "${getExe pkgs.tmux} new-session -d";
        ExecStop = "${getExe pkgs.tmux} kill-server";
        KillMode = "none";
        RestartSec = "2";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

  };
}
