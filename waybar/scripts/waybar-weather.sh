#!/bin/bash

# Script to show weather information
# For use with Waybar custom module

# Default values in case we can't get weather data
TEMP="--"
CONDITION="Unknown"
ICON="❓"
WIND="--"
HUMIDITY="--"
PRECIPITATION="--"

# Try to get weather data using curl and wttr.in
if command -v curl &> /dev/null; then
    # Get weather data for Tokyo (change to your location)
    WEATHER_DATA=$(curl -s "wttr.in/Leppington?format=%t|%C|%w|%h|%p")

    if [ $? -eq 0 ] && [ -n "$WEATHER_DATA" ]; then
        # Parse the data
        TEMP=$(echo "$WEATHER_DATA" | cut -d'|' -f1)
        CONDITION=$(echo "$WEATHER_DATA" | cut -d'|' -f2)
        WIND=$(echo "$WEATHER_DATA" | cut -d'|' -f3)
        HUMIDITY=$(echo "$WEATHER_DATA" | cut -d'|' -f4)
        PRECIPITATION=$(echo "$WEATHER_DATA" | cut -d'|' -f5)

        # Set icon based on condition
        case "$CONDITION" in
            *"Clear"*|*"Sunny"*)
                ICON="☀️"
                ;;
            *"Cloudy"*|*"Overcast"*)
                ICON="☁️"
                ;;
            *"Rain"*|*"Drizzle"*)
                ICON="🌧️"
                ;;
            *"Snow"*|*"Sleet"*)
                ICON="❄️"
                ;;
            *"Thunder"*|*"Storm"*)
                ICON="⚡"
                ;;
            *"Fog"*|*"Mist"*)
                ICON="🌫️"
                ;;
            *)
                ICON="🌡️"
                ;;
        esac
    fi
fi

# Create detailed tooltip and escape any quotes or special characters
TOOLTIP="Weather: ${CONDITION}\\nTemperature: ${TEMP}\\nWind: ${WIND}\\nHumidity: ${HUMIDITY}\\nPrecipitation: ${PRECIPITATION}"

# Output JSON for Waybar - ensure proper JSON escaping
echo "{\"text\": \"[ ${ICON} ${TEMP} ]\", \"tooltip\": \"${TOOLTIP}\"}"
