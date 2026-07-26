#!/bin/bash
PID_FILE="/tmp/mpv-whitenoise.pid"
SOCKET="/tmp/mpv-whitenoise"
STATE_FILE="/tmp/whitenoise.state"
AUDIO_FILE="$HOME/Music/white_noise.opus"

if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    python3 ~/.config/i3/scripts/whitenoise-ctl.py toggle
    sleep 0.3
    if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "paused" ]; then
        echo "playing" > "$STATE_FILE"
    else
        echo "paused" > "$STATE_FILE"
    fi
else
    rm -f "$PID_FILE" "$SOCKET" "$STATE_FILE"
    mpv --no-video --loop=inf --volume=65 \
        --input-ipc-server="$SOCKET" \
        --really-quiet \
        "$AUDIO_FILE" &
    echo $! > "$PID_FILE"
    echo "playing" > "$STATE_FILE"
    disown
fi
