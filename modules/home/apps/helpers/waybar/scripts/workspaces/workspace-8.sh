#!/usr/bin/env bash
# workspace-8.sh — highlight workspace 8 if active

active=$(hyprctl activeworkspace -j | jq '.id')

if [ "$active" -eq 8 ]; then
  echo "[<span foreground='#94e2d5'>●</span>]"
else
  echo "[VIII]"
fi
