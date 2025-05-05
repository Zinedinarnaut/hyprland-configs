#!/bin/bash

# Script to show memory usage with ASCII bar
# For use with Waybar custom module

# Get memory usage percentage - more reliable method
MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MEM_AVAILABLE=$(grep MemAvailable /proc/meminfo | awk '{print $2}')

if [ -n "$MEM_TOTAL" ] && [ -n "$MEM_AVAILABLE" ] && [ "$MEM_TOTAL" -gt 0 ]; then
    MEM_USED=$((MEM_TOTAL - MEM_AVAILABLE))
    MEM_PERCENTAGE=$((MEM_USED * 100 / $MEM_TOTAL))
else
    # Fallback value
    MEM_PERCENTAGE=50
fi

# Create advanced ASCII progress bar with better characters and orange color
BAR_LENGTH=12
FILLED_CHARS=$((MEM_PERCENTAGE * BAR_LENGTH / 100))
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
if [ "$MEM_PERCENTAGE" -gt 90 ]; then
    CLASS="critical"
elif [ "$MEM_PERCENTAGE" -gt 70 ]; then
    CLASS="warning"
fi

# Calculate used and total memory in MB for tooltip
MEM_USED_MB=$((MEM_USED / 1024))
MEM_TOTAL_MB=$((MEM_TOTAL / 1024))

# Output JSON for Waybar
echo "{\"text\": \"[ 🧠 ${MEM_PERCENTAGE}% ${BAR}]\", \"class\": \"${CLASS}\", \"percentage\": ${MEM_PERCENTAGE}, \"tooltip\": \"Memory: ${MEM_USED_MB}MB / ${MEM_TOTAL_MB}MB (${MEM_PERCENTAGE}%)\", \"alt\": \"RAM: ${MEM_PERCENTAGE}%\"}"
