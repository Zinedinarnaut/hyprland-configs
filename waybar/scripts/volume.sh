#!/bin/bash

# Script to show volume level with color changes
# For use with Waybar custom module

# Get volume using pactl
VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -1)
MUTED=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -oP '(?<=Mute: )(yes|no)')

# Default values if we can't get the volume
if [ -z "$VOLUME" ]; then
    VOLUME=0
fi

# Create advanced ASCII progress bar with color based on volume level
BAR_LENGTH=10
FILLED_CHARS=$((VOLUME * BAR_LENGTH / 100))
EMPTY_CHARS=$((BAR_LENGTH - FILLED_CHARS))

BAR="["

# Choose color based on volume level
if [ "$MUTED" = "yes" ]; then
    COLOR="#4c566a"  # Gray for muted
    CLASS="muted"
elif [ "$VOLUME" -gt 100 ]; then
    COLOR="#bf616a"  # Red for dangerous levels
    CLASS="critical"
elif [ "$VOLUME" -gt 70 ]; then
    COLOR="#a3be8c"  # Green for high volume
    CLASS="high"
elif [ "$VOLUME" -gt 30 ]; then
    COLOR="#ebcb8b"  # Yellow for medium volume
    CLASS="medium"
else
    COLOR="#81a1c1"  # Blue for low volume
    CLASS="low"
fi

# Build the progress bar
for ((i=0; i<FILLED_CHARS; i++)); do
    BAR+="<span color='${COLOR}'>█</span>"
done
for ((i=0; i<EMPTY_CHARS; i++)); do
    BAR+="<span color='#4c566a'>░</span>"
done
BAR+="]"

# Choose icon based on volume level and mute state
if [ "$MUTED" = "yes" ]; then
    ICON="🔇"
    TEXT="MUTED"
elif [ "$VOLUME" -gt 70 ]; then
    ICON="🔊"
    TEXT="${VOLUME}%"
elif [ "$VOLUME" -gt 30 ]; then
    ICON="🔉"
    TEXT="${VOLUME}%"
else
    ICON="🔈"
    TEXT="${VOLUME}%"
fi

# Create tooltip with detailed information and escape any quotes
TOOLTIP="Volume: ${VOLUME}%\\nStatus: $([ "$MUTED" = "yes" ] && echo "Muted" || echo "Active")\\nClick: Increase volume\\nRight-click: Decrease volume\\nMiddle-click: Toggle mute"

# Output JSON for Waybar - ensure proper JSON escaping
echo "{\"text\": \"[ ${ICON} ${TEXT} ${BAR} ]\", \"class\": \"${CLASS}\", \"percentage\": ${VOLUME}, \"tooltip\": \"${TOOLTIP}\"}"
