#!/bin/bash
LOG="/tmp/gpu-rec.log"
echo "=== $(date) ===" > "$LOG"

if pgrep -f gpu-screen-recorder > /dev/null; then
    killall gpu-screen-recorder
    notify-send "Recording saved"
else
    REGION=$(slurp -f "%wx%h+%x+%y")
    echo "REGION: $REGION" >> "$LOG"
    if [ -n "$REGION" ]; then
        gpu-screen-recorder -w "$REGION" -c mp4 -q high -f 60 -o "$HOME/Videos/rec-$(date +%H%M%S).mp4" >> "$LOG" 2>&1 &
        GSR_PID=$!
        notify-send "Recording started"
        wait $GSR_PID
    fi
fi
