{
  lib,
  zenith,
  ...
}:

with zenith.lib';

{
  mc-modcheck = ''
    # ── Argument parsing ───────────────────────────────────────────
    set -l verbose 0
    set -l subcmd ""
    set -l subcmd_args ""

    for arg in $argv
      switch "$arg"
        case --verbose -v
          set verbose 1
        case pin
          set subcmd "pin"
        case --list
          set subcmd_args "$subcmd_args $arg"
        case '*'
          if test "$subcmd" = "pin"
            set subcmd_args "$subcmd_args $arg"
          end
      end
    end

    set -l server ""
    for arg in $argv
      switch "$arg"
        case --verbose -v pin --list
          # skip flags
        case '*'
          if test -z "$server"
            set server "$arg"
          end
      end
    end

    if test -z "$server"
      printf "${colors.helios.red.ansi}Error:${ansiReset} ${colors.helios.text.ansi}Usage: mc-modcheck ${colors.helios.blue.ansi}<server>${ansiReset} ${colors.helios.text.ansi}[--verbose]${ansiReset}\n"
      printf "       mc-modcheck ${colors.helios.blue.ansi}$server${ansiReset} ${colors.helios.peach.ansi}pin${ansiReset} ${colors.helios.text.ansi}<mod-slug>${ansiReset}\n"
      printf "       mc-modcheck ${colors.helios.blue.ansi}$server${ansiReset} ${colors.helios.peach.ansi}pin --list${ansiReset}\n"
      return 1
    end

    # ── Pin subcommand ─────────────────────────────────────────────
    if test "$subcmd" = "pin"
      set -l pin_dir "$HOME/.local/state/mc-modcheck"
      set -l pin_file "$pin_dir/pinned"
      mkdir -p "$pin_dir"
      touch "$pin_file"

      set -l slug (string trim -- "$subcmd_args")

      if test "$slug" = "--list"
        printf "${colors.helios.blue.ansi}Pinned components for ${colors.helios.peach.ansi}$server${colors.helios.blue.ansi}:${colors.helios.text.ansi}\n"
        if test -s "$pin_file"
          while read -l line
            printf "  ${colors.helios.yellow.ansi}$line${colors.helios.text.ansi}\n"
          end < "$pin_file"
        else
          printf "  ${colors.helios.text.ansi}(none)${colors.helios.text.ansi}\n"
        end
        return 0
      end

      if test -z "$slug"
        printf "${colors.helios.red.ansi}Error:${ansiReset} ${colors.helios.text.ansi}Specify a mod slug to pin.${ansiReset}\n"
        return 1
      end

      if grep -qxF "$slug" "$pin_file"
        begin
          set -l found 0
          for line in (cat "$pin_file")
            if test "$line" != "$slug"
              if test $found -eq 1
                printf "%s\n" "$line"
              else
                printf "%s" "$line"
                set found 1
              end
            end
          end
          if test $found -eq 1
            printf "\n"
          end
        end > "$pin_file.tmp"
        mv "$pin_file.tmp" "$pin_file"
        printf "${colors.helios.green.ansi}Unpinned${ansiReset} ${colors.helios.blue.ansi}$slug${colors.helios.text.ansi}\n"
      else
        echo "$slug" >> "$pin_file"
        printf "${colors.helios.peach.ansi}Pinned${ansiReset} ${colors.helios.blue.ansi}$slug${colors.helios.text.ansi}\n"
      end
      return 0
    end

    # ── Read version registry ──────────────────────────────────────
    set -l json_file "/run/current-system/etc/mc-modcheck.json"
    if not test -f "$json_file"
      printf "${colors.helios.red.ansi}Error:${ansiReset} ${colors.helios.text.ansi}Version registry not found at${ansiReset}\n"
      printf "  ${colors.helios.blue.ansi}$json_file${colors.helios.text.ansi}\n"
      printf "${colors.helios.text.ansi}Run${ansiReset} ${colors.helios.green.ansi}nh os switch${colors.helios.text.ansi} to rebuild first.${colors.helios.text.ansi}\n"
      return 1
    end

    set -l pin_file "$HOME/.local/state/mc-modcheck/pinned"
    set -l pinned_list ""
    if test -f "$pin_file"
      set pinned_list (cat "$pin_file")
    end

    set -l mc_version (jq -r '.mcVersion' "$json_file")

    printf "${colors.helios.green.ansi}->${ansiReset} ${colors.helios.peach.ansi}Checking ${colors.helios.blue.ansi}$server${colors.helios.peach.ansi} mod versions${colors.helios.text.ansi} (MC ${colors.helios.blue.ansi}$mc_version${colors.helios.text.ansi})${colors.helios.text.ansi}...\n\n"

    set -l outdated 0
    set -l checks ""

    # ── Fabric loader ──────────────────────────────────────────────
    set -l slug "fabric-loader"
    if not contains -- "$slug" $pinned_list
      set -l pinned_ver (jq -r '.fabricLoader.version' "$json_file")
      set -l api_url "https://meta.fabricmc.net/v2/versions/loader"
      if test $verbose -eq 1
        printf "${colors.helios.overlay0.ansi}  [verbose] GET $api_url${colors.helios.text.ansi}\n"
      end
      set -l resp (curl -s --max-time 10 "$api_url" 2>/dev/null)
      set -l latest_ver (echo "$resp" | jq -r '[.[] | select(.stable == true)][0].version // empty' 2>/dev/null)
      if test -n "$latest_ver"; and test "$pinned_ver" != "$latest_ver"
        set checks $checks "$slug|$pinned_ver|$latest_ver|outdated"
        set outdated (math $outdated + 1)
      else
        set checks $checks "$slug|$pinned_ver|$pinned_ver|ok"
      end
    end

    # ── Fabric installer ───────────────────────────────────────────
    set -l slug "fabric-installer"
    if not contains -- "$slug" $pinned_list
      set -l pinned_ver (jq -r '.fabricInstaller.version' "$json_file")
      set -l api_url "https://meta.fabricmc.net/v2/versions/installer"
      if test $verbose -eq 1
        printf "${colors.helios.overlay0.ansi}  [verbose] GET $api_url${colors.helios.text.ansi}\n"
      end
      set -l resp (curl -s --max-time 10 "$api_url" 2>/dev/null)
      set -l latest_ver (echo "$resp" | jq -r '[.[] | select(.stable == true)][0].version // empty' 2>/dev/null)
      if test -n "$latest_ver"; and test "$pinned_ver" != "$latest_ver"
        set checks $checks "$slug|$pinned_ver|$latest_ver|outdated"
        set outdated (math $outdated + 1)
      else
        set checks $checks "$slug|$pinned_ver|$pinned_ver|ok"
      end
    end

    # ── Modrinth mods ──────────────────────────────────────────────
    set -l mod_slugs (jq -r '.mods | keys[]' "$json_file")
    for mod_slug in $mod_slugs
      if contains -- "$mod_slug" $pinned_list
        continue
      end
      set -l project_id (jq -r ".mods[\"$mod_slug\"].projectId" "$json_file")
      set -l pinned_ver (jq -r ".mods[\"$mod_slug\"].version" "$json_file")
      set -l pinned_url "https://cdn.modrinth.com/data/$project_id/versions/"
      set -l api_url "https://api.modrinth.com/v2/project/$project_id/version"
      if test $verbose -eq 1
        printf "${colors.helios.overlay0.ansi}  [verbose] GET $api_url?loaders=[\"fabric\"]&game_versions=[\"$mc_version\"]${colors.helios.text.ansi}\n"
      end
      set -l resp (curl -s --max-time 10 -G "$api_url" --data-urlencode "loaders=[\"fabric\"]" --data-urlencode "game_versions=[\"$mc_version\"]" 2>/dev/null)
      if test $verbose -eq 1; and test -n "$resp"
        printf "${colors.helios.overlay0.ansi}  [verbose] Response: $(echo "$resp" | head -c 200)${colors.helios.text.ansi}\n"
      end
      # Compare download URLs — version_number formats vary wildly between mods
      set -l latest_url (echo "$resp" | jq -r '.[0].files[0].url // empty' 2>/dev/null)
      set -l latest_ver (echo "$resp" | jq -r '.[0].version_number // empty' 2>/dev/null)
      if test -n "$latest_url"; and not string match -q -- "$pinned_url*" "$latest_url"
        set checks $checks "$mod_slug|$pinned_ver|$latest_ver|outdated"
        set outdated (math $outdated + 1)
      else
        set checks $checks "$mod_slug|$pinned_ver|$pinned_ver|ok"
      end
      sleep 0.1
    end

    # ── GitHub addons ──────────────────────────────────────────────
    set -l addon_slugs (jq -r '.addons | keys[]' "$json_file")
    for addon_slug in $addon_slugs
      set -l source (jq -r ".addons[\"$addon_slug\"].source" "$json_file")
      if test "$source" != "github"
        if contains -- "$addon_slug" $pinned_list
          continue
        end
        if test "$addon_slug" = "geyser-viaproxy"
          set -l pinned_ver (jq -r ".addons[\"$addon_slug\"].version" "$json_file")
          set -l api_url "https://download.geysermc.org/v2/projects/geyser/versions/latest"
          if test $verbose -eq 1
            printf "${colors.helios.overlay0.ansi}  [verbose] GET $api_url${colors.helios.text.ansi}\n"
          end
          set -l resp (curl -sL --max-time 10 -o /dev/null -w '%{url_effective}' "$api_url" 2>/dev/null)
          set -l latest_ver (echo "$resp" | sed -n 's|.*/\([0-9][0-9.]*\)$|\1|p')
          if test -n "$latest_ver"; and test "$pinned_ver" != "$latest_ver"
            set checks $checks "$addon_slug|$pinned_ver|$latest_ver|outdated"
            set outdated (math $outdated + 1)
          else
            set checks $checks "$addon_slug|$pinned_ver|$pinned_ver|ok"
          end
        end
        continue
      end

      if contains -- "$addon_slug" $pinned_list
        continue
      end
      set -l pinned_ver (jq -r ".addons[\"$addon_slug\"].version" "$json_file")
      set -l repo (jq -r ".addons[\"$addon_slug\"].repo" "$json_file")
      set -l note (jq -r ".addons[\"$addon_slug\"].note // empty" "$json_file")
      set -l api_url "https://api.github.com/repos/$repo/releases/latest"
      if test $verbose -eq 1
        printf "${colors.helios.overlay0.ansi}  [verbose] GET $api_url${colors.helios.text.ansi}\n"
      end
      set -l resp (curl -s --max-time 10 "$api_url" 2>/dev/null)
      if test $verbose -eq 1; and test -n "$resp"
        printf "${colors.helios.overlay0.ansi}  [verbose] Response: $(echo "$resp" | head -c 200)${colors.helios.text.ansi}\n"
      end
      set -l latest_ver (echo "$resp" | jq -r '.tag_name // empty' 2>/dev/null | sed 's/^v//')
      if test -n "$latest_ver"; and test "$pinned_ver" != "$latest_ver"
        set checks $checks "$addon_slug|$pinned_ver|$latest_ver|outdated"
        set outdated (math $outdated + 1)
      else
        set checks $checks "$addon_slug|$pinned_ver|$pinned_ver|ok"
      end
    end

    # ── Print results table ────────────────────────────────────────
    set -l sep (string repeat --count=22 '─')" "(string repeat --count=12 '─')" "(string repeat --count=12 '─')" "(string repeat --count=14 '─')
    printf "  ${colors.helios.text.ansi}%-22s %-12s %-12s %s${colors.helios.text.ansi}\n" "Component" "Current" "Latest" "Status"
    printf "  ${colors.helios.overlay0.ansi}%s${colors.helios.text.ansi}\n" "$sep"

    for entry in $checks
      set -l parts (string split "|" -- "$entry")
      set -l name $parts[1]
      set -l current $parts[2]
      set -l latest $parts[3]
      set -l result $parts[4]

      if test "$result" = "outdated"
        set -l note (jq -r ".addons[\"$name\"].note // empty" "$json_file" 2>/dev/null)
        if test -n "$note"
          printf "  ${colors.helios.text.ansi}%-22s ${colors.helios.text.ansi}%-12s ${colors.helios.yellow.ansi}%-12s ${colors.helios.red.ansi}%-6s ${colors.helios.overlay0.ansi}(%s)${colors.helios.text.ansi}\n" "$name" "$current" "$latest" "update" "$note"
        else
          printf "  ${colors.helios.text.ansi}%-22s ${colors.helios.text.ansi}%-12s ${colors.helios.yellow.ansi}%-12s ${colors.helios.red.ansi}%s${colors.helios.text.ansi}\n" "$name" "$current" "$latest" "update"
        end
      else
        printf "  ${colors.helios.text.ansi}%-22s ${colors.helios.text.ansi}%-12s ${colors.helios.text.ansi}%-12s ${colors.helios.green.ansi}%s${colors.helios.text.ansi}\n" "$name" "$current" "$current" "ok"
      end
    end

    printf "\n"
    if test $outdated -gt 0
      printf "  ${colors.helios.yellow.ansi}$outdated${colors.helios.text.ansi} update(s) available.${colors.helios.text.ansi}\n"
      printf "  ${colors.helios.text.ansi}Edit${colors.helios.green.ansi} versions.nix${colors.helios.text.ansi} and run: ${colors.helios.green.ansi}nh os switch${colors.helios.text.ansi}\n"
    else
      printf "  ${colors.helios.green.ansi}All components up to date.${colors.helios.text.ansi}\n"
    end
  '';
}
