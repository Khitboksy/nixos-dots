#!/usr/bin/env bash
# workspace-0.sh — highlight workspace 10 if active

active=$(hyprctl activeworkspace -j | jq '.id')

if [ "$active" -eq 10 ]; then
  echo "[<span foreground='#74c7ec'>●</span>]"
else
  echo "[X]"
fi
