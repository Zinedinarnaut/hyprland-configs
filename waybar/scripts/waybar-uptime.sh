#!/bin/bash

# Script to show system uptime
# For use with Waybar custom module

# Get uptime in seconds
UPTIME_SECONDS=$(cat /proc/uptime | awk '{print int($1)}')

# Convert to days, hours, minutes
DAYS=$((UPTIME_SECONDS / 86400))
HOURS=$(( (UPTIME_SECONDS % 86400) / 3600 ))
MINUTES=$(( (UPTIME_SECONDS % 3600) / 60 ))

# Format uptime string
if [ $DAYS -gt 0 ]; then
    UPTIME_TEXT="${DAYS}d ${HOURS}h ${MINUTES}m"
elif [ $HOURS -gt 0 ]; then
    UPTIME_TEXT="${HOURS}h ${MINUTES}m"
else
    UPTIME_TEXT="${MINUTES}m"
fi

# Create ASCII progress bar for uptime (resets after 7 days)
MAX_UPTIME=$((7 * 24 * 60 * 60))  # 7 days in seconds
UPTIME_PERCENTAGE=$((UPTIME_SECONDS * 100 / MAX_UPTIME))
if [ $UPTIME_PERCENTAGE -gt 100 ]; then
    UPTIME_PERCENTAGE=100
fi

BAR_LENGTH=10
FILLED_CHARS=$((UPTIME_PERCENTAGE * BAR_LENGTH / 100))
EMPTY_CHARS=$((BAR_LENGTH - FILLED_CHARS))

BAR="["
for ((i=0; i<FILLED_CHARS; i++)); do
    BAR+="<span color='#5e81ac'>▰</span>"
done
for ((i=0; i<EMPTY_CHARS; i++)); do
    BAR+="<span color='#4c566a'>▱</span>"
done
BAR+="]"

# Create tooltip with boot time
BOOT_TIME=$(uptime -s)
TOOLTIP="System Uptime: ${UPTIME_TEXT}\\nSystem booted at: ${BOOT_TIME}\\nUptime progress bar shows percentage of 7-day cycle"

# Output JSON for Waybar
echo "{\"text\": \"[ ⏱️ UP ${UPTIME_TEXT} ${BAR} ]\", \"tooltip\": \"${TOOLTIP}\", \"alt\": \"Uptime: ${UPTIME_TEXT}\"}"
