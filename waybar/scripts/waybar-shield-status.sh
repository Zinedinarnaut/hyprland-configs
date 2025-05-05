#!/bin/bash

# Script to dynamically update the shield status with ASCII visualization
# For use with Waybar custom module

# Try to get system temperature, with fallbacks
TEMP=""

# Try to get temperature from thermal zone
if [ -f "/sys/class/thermal/thermal_zone0/temp" ]; then
    TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
    # Convert from millidegrees to degrees
    TEMP=$((TEMP / 1000))
fi

# If that failed, try sensors command
if [ -z "$TEMP" ] && command -v sensors &> /dev/null; then
    TEMP=$(sensors | grep -i "Package id 0" | awk '{print $4}' | tr -d '+°C')
    # If no temperature found, try another pattern
    if [ -z "$TEMP" ]; then
        TEMP=$(sensors | grep -i "CPU Temperature" | awk '{print $3}' | tr -d '+°C')
    fi
fi

# If still no temperature, use a default value
if [ -z "$TEMP" ] || [ "$TEMP" -lt 0 ] || [ "$TEMP" -gt 100 ]; then
    TEMP=40  # Default value
fi

# Calculate shield strength (inverse of temperature)
MAX_TEMP=100
SHIELD_STRENGTH=$((MAX_TEMP - TEMP))
if [ "$SHIELD_STRENGTH" -lt 0 ]; then
    SHIELD_STRENGTH=0
fi

# Create advanced ASCII progress bar with better characters and orange color
BAR_LENGTH=12
FILLED_CHARS=$((SHIELD_STRENGTH * BAR_LENGTH / 100))
EMPTY_CHARS=$((BAR_LENGTH - FILLED_CHARS))

BAR="["
for ((i=0; i<FILLED_CHARS; i++)); do
    BAR+="<span color='#d08770'>▰</span>"
done
for ((i=0; i<EMPTY_CHARS; i++)); do
    BAR+="<span color='#4c566a'>▱</span>"
done
BAR+="]"

# Determine class and text based on shield strength
CLASS=""
ICON="🛡️"  # Shield icon
if [ "$SHIELD_STRENGTH" -lt 20 ]; then
    TEXT="SHIELDS CRITICAL"
    CLASS="critical"
elif [ "$SHIELD_STRENGTH" -lt 50 ]; then
    TEXT="SHIELDS WEAKENED"
    CLASS="warning"
else
    TEXT="SHIELDS"
    CLASS=""
fi

# Create tooltip with detailed information
TOOLTIP="Shield Status: ${TEXT}\\nShield Strength: ${SHIELD_STRENGTH}%\\nSystem Temperature: ${TEMP}°C\\nMax Safe Temperature: ${MAX_TEMP}°C"

# Output JSON for Waybar
echo "{\"text\": \"[${ICON} ${SHIELD_STRENGTH}% ${BAR}]\", \"class\": \"${CLASS}\", \"tooltip\": \"${TOOLTIP}\", \"alt\": \"Shields: ${SHIELD_STRENGTH}%\"}"
