#!/usr/bin/env bash
# workspace-2.sh — highlight workspace 2 if active

active=$(hyprctl activeworkspace -j | jq '.id')

if [ "$active" -eq 2 ]; then
  echo "[<span foreground='#cba6f7'>●</span>]"
else
  echo "[II]"
fi
