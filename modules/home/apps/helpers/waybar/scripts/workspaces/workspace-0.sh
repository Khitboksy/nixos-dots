#!/usr/bin/env bash
# workspace-0.sh — highlight workspace 10 if active

active=$(hyprctl activeworkspace -j | jq '.id')

if [ "$active" -eq 10 ]; then
  echo "[<span foreground='#fab387'>●</span>]"
else
  echo "[X]"
fi
