#!/usr/bin/env bash
# Close the focused window.
#
# qutebrowser is handled specially: a plain i3 `kill` would drop it without
# writing the session, so we send it its own quit key instead, which runs
# `quit --save` (bound to `x` via the alias in config.py).

set -u

tree=$(i3-msg -t get_tree 2>/dev/null)

focused_class=$(echo "$tree" | jq -r 'recurse(.nodes[]?) | select(.focused == true and .window_properties != null) | .window_properties.class' 2>/dev/null | head -1)
focused_id=$(echo "$tree" | jq -r 'recurse(.nodes[]?) | select(.focused == true and .window_properties != null) | .id' 2>/dev/null | head -1)

if [[ "$focused_class" == "qutebrowser" && -n "${focused_id:-}" ]]; then
    i3-msg send "$focused_id" x >/dev/null 2>&1 && exit 0
fi

i3-msg kill >/dev/null 2>&1