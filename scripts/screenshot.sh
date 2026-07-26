#!/usr/bin/env bash

set -euo pipefail

SCREENSHOTS_DIR="$HOME/Pictures/screenshots"
RECORDINGS_DIR="$HOME/Videos/recordings"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
PIDFILE="/tmp/screenshot_record.pid"

mkdir -p "$SCREENSHOTS_DIR" "$RECORDINGS_DIR"

save_and_clip() {
    local path="$1"
    shift
    maim "$@" | tee "$path" | xclip -selection clipboard -t image/png
    notify "Screenshot saved" "$(basename "$path")" "$path"
}

save_only() {
    local path="$1"
    shift
    maim "$@" "$path"
    notify "Screenshot saved" "$(basename "$path")" "$path"
}

clip_only() {
    maim "$@" | xclip -selection clipboard -t image/png
    notify "Screenshot copied" "Image copied to clipboard"
}

notify() {
    local title="$1" msg="$2"
    local file="${3:-}"
    if [[ -n "$file" ]]; then
        dunstify -a screenshot -i image-x-generic \
            -h "string:x-dunst-stack-tag:screenshot" \
            --action="delete,Delete" \
            "$title" "$msg"
        case "$?" in
            2) rm -f "$file" && dunstify -a screenshot "Screenshot deleted" "$(basename "$file")" ;;
        esac
    else
        dunstify -a screenshot -i image-x-generic \
            -h "string:x-dunst-stack-tag:screenshot" \
            "$title" "$msg"
    fi
}

toggle_record() {
    if [[ -f "$PIDFILE" ]]; then
        local pid
        pid=$(cat "$PIDFILE")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            rm -f "$PIDFILE"
            dunstify -a screenshot "Recording stopped" "Saved to $RECORDINGS_DIR"
            return
        fi
        rm -f "$PIDFILE"
    fi
    local output="$RECORDINGS_DIR/recording_$TIMESTAMP.mp4"
    ffmpeg -f x11grab -s 1920x1080 -i :0.0 -f pulse -i default \
        -c:v libx264 -preset ultrafast -crf 23 \
        -c:a aac -b:a 128k \
        "$output" &
    echo $! > "$PIDFILE"
    dunstify -a screenshot "Recording started" "Output: $(basename "$output")"
}

case "${1:-}" in
    select)
        save_and_clip "$SCREENSHOTS_DIR/screenshot_$TIMESTAMP.png" -s -u
        ;;
    full)
        save_only "$SCREENSHOTS_DIR/screenshot_$TIMESTAMP.png" -u
        ;;
    window)
        local wid
        wid=$(xdotool getactivewindow)
        save_and_clip "$SCREENSHOTS_DIR/screenshot_$TIMESTAMP.png" -i "$wid" -u
        ;;
    clip-select)
        clip_only -s -u
        ;;
    record)
        toggle_record
        ;;
    *)
        echo "Usage: $0 {select|full|window|clip-select|record}"
        exit 1
        ;;
esac
