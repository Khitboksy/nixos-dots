#!/usr/bin/env bash
# workspace-4.sh — highlight workspace 4 if active

active=$(hyprctl activeworkspace -j | jq '.id')

if [ "$active" -eq 4 ]; then
  echo "[<span foreground='#fab387'>●</span>]"
else
  echo "[IV]"
fi
