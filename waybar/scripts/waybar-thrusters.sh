#!/bin/bash

# Script to dynamically update the thrusters status with ASCII visualization
# For use with Waybar custom module

# Simplified approach - use a random value with some persistence
THRUSTER_LEVEL_FILE="/tmp/waybar_thruster_level"

# If the file exists, read the value and slightly modify it
if [ -f "$THRUSTER_LEVEL_FILE" ]; then
    THRUSTER_LEVEL=$(cat "$THRUSTER_LEVEL_FILE")

    # Add some random variation (-5 to +5)
    VARIATION=$((RANDOM % 11 - 5))
    THRUSTER_LEVEL=$((THRUSTER_LEVEL + VARIATION))

    # Keep within bounds
    if [ "$THRUSTER_LEVEL" -lt 20 ]; then
        THRUSTER_LEVEL=20
    elif [ "$THRUSTER_LEVEL" -gt 100 ]; then
        THRUSTER_LEVEL=100
    fi
else
    # Initial value between 70 and 100
    THRUSTER_LEVEL=$((RANDOM % 31 + 70))
fi

# Save the current value for next time
echo "$THRUSTER_LEVEL" > "$THRUSTER_LEVEL_FILE"

# Create advanced ASCII progress bar with better characters and BLUE color (this one stays blue)
BAR_LENGTH=12
FILLED_CHARS=$((THRUSTER_LEVEL * BAR_LENGTH / 100))
EMPTY_CHARS=$((BAR_LENGTH - FILLED_CHARS))

BAR="["
for ((i=0; i<FILLED_CHARS; i++)); do
    BAR+="<span color='#88c0d0'>▰</span>"
done
for ((i=0; i<EMPTY_CHARS; i++)); do
    BAR+="<span color='#4c566a'>▱</span>"
done
BAR+="]"

# Determine class and text based on thruster level
CLASS=""
ICON="🚀"  # Rocket icon for thrusters
if [ "$THRUSTER_LEVEL" -lt 20 ]; then
    TEXT="THRUSTERS CRITICAL"
    CLASS="critical"
elif [ "$THRUSTER_LEVEL" -lt 50 ]; then
    TEXT="THRUSTERS LIMITED"
    CLASS="warning"
else
    TEXT="THRUSTERS"
    CLASS=""
fi

# Calculate fuel efficiency based on thruster level
EFFICIENCY=$((THRUSTER_LEVEL - 20))
if [ "$EFFICIENCY" -lt 0 ]; then
    EFFICIENCY=0
fi

# Create tooltip with detailed information
TOOLTIP="Thruster Status: ${TEXT}\\nThruster Power: ${THRUSTER_LEVEL}%\\nFuel Efficiency: ${EFFICIENCY}%\\nEstimated Range: $((THRUSTER_LEVEL * 10)) light-years"

# Output JSON for Waybar
echo "{\"text\": \"[${ICON} ${THRUSTER_LEVEL}% ${BAR}]\", \"class\": \"${CLASS}\", \"tooltip\": \"${TOOLTIP}\", \"alt\": \"Thrusters: ${THRUSTER_LEVEL}%\"}"
