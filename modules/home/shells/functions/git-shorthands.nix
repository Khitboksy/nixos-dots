{
  # Git shorthand functions
  #
  # These replace the old command-scoped abbreviations which were broken by
  # Fish 4.8.0's change to `--command` (now single-word only).
  #
  # With functions, the shorthand stays as-is while typing and only
  # translates to the full command when you press Enter.
  #
  # Example: typing "gu o m" + Enter runs "git push origin main"

  # ── ga: git add ──────────────────────────────────────────────────────
  ga = ''
    set -l expanded_args
    for arg in $argv
      switch $arg
        case a
          set -a expanded_args -A
        case '*'
          set -a expanded_args $arg
      end
    end
    git add $expanded_args
  '';

  # ── gc: git commit ───────────────────────────────────────────────────
  gc = ''
    switch (count $argv)
      case 0
        git commit
      case 1
        switch $argv[1]
          case a
            git commit --amend
          case '*'
            git commit $argv
        end
      case '*'
        switch $argv[1]
          case m
            # gc m "message" -> git commit -m "message"
            if test (count $argv) -ge 2
              git commit -m $argv[2..-1]
            else
              echo "usage: gc m \"message\"" >&2
              return 1
            end
          case a
            switch $argv[2]
              case n
                # gc a n -> git commit --amend --no-edit
                git commit --amend --no-edit
              case m
                # gc a m "message" -> git commit --amend -m "message"
                if test (count $argv) -ge 3
                  git commit --amend -m $argv[3..-1]
                else
                  echo "usage: gc a m \"message\"" >&2
                  return 1
                end
              case '*'
                echo "usage: gc a n | gc a m \"message\"" >&2
                return 1
            end
          case '*'
            git commit $argv
        end
    end
  '';

  # ── gu: git push ─────────────────────────────────────────────────────
  gu = ''
    set -l expanded_args
    for arg in $argv
      switch $arg
        case o
          set -a expanded_args origin
        case m
          set -a expanded_args main
        case f
          set -a expanded_args --force-with-lease
        case ff
          set -a expanded_args --force
        case '*'
          set -a expanded_args $arg
      end
    end
    git push $expanded_args
  '';

  # ── gd: git pull ─────────────────────────────────────────────────────
  gd = ''
    set -l expanded_args
    for arg in $argv
      switch $arg
        case o
          set -a expanded_args origin
        case r
          set -a expanded_args --rebase
        case '*'
          set -a expanded_args $arg
      end
    end
    git pull $expanded_args
  '';

  # ── gco: git checkout ────────────────────────────────────────────────
  gco = ''
    set -l expanded_args
    for arg in $argv
      switch $arg
        case b
          set -a expanded_args -b
        case B
          set -a expanded_args -B
        case '*'
          set -a expanded_args $arg
      end
    end
    git checkout $expanded_args
  '';

  # ── gsw: git switch ──────────────────────────────────────────────────
  gsw = ''
    set -l expanded_args
    for arg in $argv
      switch $arg
        case c
          set -a expanded_args -c
        case '*'
          set -a expanded_args $arg
      end
    end
    git switch $expanded_args
  '';

  # ── gb: git branch ───────────────────────────────────────────────────
  gb = ''
    set -l expanded_args
    for arg in $argv
      switch $arg
        case d
          set -a expanded_args --delete
        case D
          set -a expanded_args --delete --force
        case m
          set -a expanded_args --move
        case a
          set -a expanded_args --all
        case '*'
          set -a expanded_args $arg
      end
    end
    git branch $expanded_args
  '';

  # ── grb: git rebase ──────────────────────────────────────────────────
  grb = ''
    set -l expanded_args
    for arg in $argv
      switch $arg
        case i
          set -a expanded_args -i
        case c
          set -a expanded_args --continue
        case s
          set -a expanded_args --skip
        case a
          set -a expanded_args --abort
        case '*'
          set -a expanded_args $arg
      end
    end
    git rebase $expanded_args
  '';
}
