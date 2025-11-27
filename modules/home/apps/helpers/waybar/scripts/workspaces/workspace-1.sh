#!/usr/bin/env bash
# workspace-1.sh — highlight workspace 1 if active

active=$(hyprctl activeworkspace -j | jq '.id')

if [ "$active" -eq 1 ]; then
  echo "[<span foreground='#f5c2e7'>●</span>]"
else
  echo "[I]"
fi
