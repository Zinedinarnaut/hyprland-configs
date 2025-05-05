#!/bin/bash

# Script to show CPU usage with ASCII bar
# For use with Waybar custom module

# Get CPU usage percentage - more reliable method with error handling
CPU_USAGE=$(grep 'cpu ' /proc/stat | awk '{if(($2+$4+$5)>0) usage=($2+$4)*100/($2+$4+$5); else usage=0} END {print int(usage)}')

# If that fails, use a fallback
if [ -z "$CPU_USAGE" ] || [ "$CPU_USAGE" -lt 0 ] || [ "$CPU_USAGE" -gt 100 ]; then
    CPU_USAGE=50  # Default value
fi

# Create advanced ASCII progress bar with better characters and orange color
BAR_LENGTH=12
FILLED_CHARS=$((CPU_USAGE * BAR_LENGTH / 100))
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
if [ "$CPU_USAGE" -gt 90 ]; then
    CLASS="critical"
elif [ "$CPU_USAGE" -gt 70 ]; then
    CLASS="warning"
fi

# Get CPU model for tooltip
CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -n 1 | sed 's/model name\s*: //g')
if [ -z "$CPU_MODEL" ]; then
    CPU_MODEL="CPU"
fi

# Output JSON for Waybar
echo "{\"text\": \"[ 💻 ${CPU_USAGE}% ${BAR}]\", \"class\": \"${CLASS}\", \"percentage\": ${CPU_USAGE}, \"tooltip\": \"${CPU_MODEL} at ${CPU_USAGE}% usage\", \"alt\": \"CPU: ${CPU_USAGE}%\"}"
