#!/bin/bash

# Script to show disk usage with ASCII bar
# For use with Waybar custom module

# Get disk usage percentage
DISK_USED=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')

# Check if we got a valid number
if [ -z "$DISK_USED" ] || [ "$DISK_USED" -lt 0 ] || [ "$DISK_USED" -gt 100 ]; then
    DISK_USED=50  # Default value
fi

DISK_FREE=$((100 - $DISK_USED))

# Create advanced ASCII progress bar with better characters and orange color
BAR_LENGTH=12
FILLED_CHARS=$((DISK_FREE * BAR_LENGTH / 100))
EMPTY_CHARS=$((BAR_LENGTH - FILLED_CHARS))

BAR="["
for ((i=0; i<FILLED_CHARS; i++)); do
    BAR+="<span color='#d08770'>▰</span>"
done
for ((i=0; i<EMPTY_CHARS; i++)); do
    BAR+="<span color='#4c566a'>▱</span>"
done
BAR+="]"

# Determine class based on usage
CLASS=""
if [ "$DISK_USED" -gt 90 ]; then
    CLASS="critical"
elif [ "$DISK_USED" -gt 70 ]; then
    CLASS="warning"
fi

# Get disk size information for tooltip
DISK_INFO=$(df -h / | awk 'NR==2 {print $2 " total, " $3 " used, " $4 " free"}')

# Output JSON for Waybar
echo "{\"text\": \"[ 💾 ${DISK_FREE}% ${BAR}]\", \"class\": \"${CLASS}\", \"percentage\": ${DISK_FREE}, \"tooltip\": \"Disk: ${DISK_INFO} (${DISK_FREE}% free)\", \"alt\": \"Disk: ${DISK_FREE}% free\"}"
