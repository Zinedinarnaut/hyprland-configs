#!/bin/bash

# Script to dynamically update the reactor status with ASCII visualization
# For use with Waybar custom module

# Get CPU load to determine reactor state - more reliable method with error handling
CPU_LOAD=$(grep 'cpu ' /proc/stat | awk '{if(($2+$4+$5)>0) usage=($2+$4)*100/($2+$4+$5); else usage=0} END {print int(usage)}')

# Check if we got a valid number
if [ -z "$CPU_LOAD" ] || [ "$CPU_LOAD" -lt 0 ] || [ "$CPU_LOAD" -gt 100 ]; then
    CPU_LOAD=50  # Default value
fi

# Get CPU temperature if available
TEMP=""
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

# Create advanced ASCII progress bar with better characters and orange color
BAR_LENGTH=12
FILLED_CHARS=$((CPU_LOAD * BAR_LENGTH / 100))
EMPTY_CHARS=$((BAR_LENGTH - FILLED_CHARS))

BAR="["
for ((i=0; i<FILLED_CHARS; i++)); do
    BAR+="<span color='#d08770'>▰</span>"
done
for ((i=0; i<EMPTY_CHARS; i++)); do
    BAR+="<span color='#4c566a'>▱</span>"
done
BAR+="]"

# Determine reactor state based on CPU load
CLASS=""
ICON="⚛"  # Atom symbol as reactor icon
if [ "$CPU_LOAD" -gt 80 ]; then
    TEXT="REACTOR CRITICAL"
    CLASS="critical"
elif [ "$CPU_LOAD" -gt 60 ]; then
    TEXT="REACTOR OVERLOAD"
    CLASS="warning"
elif [ "$CPU_LOAD" -gt 40 ]; then
    TEXT="REACTOR ACTIVE"
    CLASS=""
elif [ "$CPU_LOAD" -gt 20 ]; then
    TEXT="REACTOR NOMINAL"
    CLASS=""
else
    TEXT="REACTOR SLEEP"
    CLASS=""
fi

# Create a more detailed tooltip
TOOLTIP="Reactor Status: ${TEXT}\\nCPU Load: ${CPU_LOAD}%\\nTemperature: ${TEMP}°C\\nEfficiency: $((100 - CPU_LOAD))%"

# Output JSON for Waybar
echo "{\"text\": \"[${ICON}] ${TEXT} [${BAR}]\", \"class\": \"${CLASS}\", \"tooltip\": \"${TOOLTIP}\", \"alt\": \"Reactor: ${CPU_LOAD}%\"}"
