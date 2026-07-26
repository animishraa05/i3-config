#!/bin/bash
# Replicates dmenu_run's functionality without the zsh dependency.
# It gets a list of executables from dmenu_path, lets the user select one with dmenu,
# and then executes the selected program.

history_file="$HOME/.local/share/dmenu_run_history"

# Function to generate dmenu input with history priority
generate_dmenu_input() {
  local history_items
  if [ -f "$history_file" ]; then
    # Read history items, most recent first
    # Using 'head -n 50' to limit history items to process for input
    mapfile -t history_items < <(tac "$history_file" | head -n 50)
  fi

  # Combine history items and dmenu_path output, then deduplicate
  {
    for item in "${history_items[@]}"; do
      echo "$item"
    done
    /sbin/dmenu_path
  } | awk '!seen[$0]++' # Deduplicate, keeping first occurrence (history prioritized)
}

selected=$(generate_dmenu_input | dmenu -l 10 -fn 'monospace-10' -nb '#2E3440' -nf '#D8DEE9' -sb '#5E81AC' -sf '#ECEFF4')

if [ -n "$selected" ]; then
  # Ensure the directory for history file exists
  mkdir -p "$(dirname "$history_file")"
  
  # Add the selected item to history, remove duplicates, and keep the last 50 unique entries
  # Using a temporary file for atomic update
  { echo "$selected"; cat "$history_file" 2>/dev/null; } | awk '!x[$0]++' | head -n 50 > "$history_file.tmp" && mv "$history_file.tmp" "$history_file"

  i3-msg exec "$selected"
fi
