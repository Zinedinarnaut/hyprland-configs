#!/bin/bash

# Script to toggle between different Waybar themes
# Usage: ./toggle-waybar-theme.sh [normal|red-alert|amber]

WAYBAR_CONFIG="$HOME/.config/waybar/config"
CURRENT_CLASS=$(grep -oP 'class="[^"]*"' "$WAYBAR_CONFIG" | cut -d'"' -f2)

case "$1" in
    "normal")
        sed -i 's/class="[^"]*"/class=""/' "$WAYBAR_CONFIG"
        echo "Switched to normal mode"
        ;;
    "red-alert")
        sed -i 's/class="[^"]*"/class="red-alert"/' "$WAYBAR_CONFIG"
        echo "RED ALERT: All hands to battle stations!"
        ;;
    "amber")
        sed -i 's/class="[^"]*"/class="amber-mode"/' "$WAYBAR_CONFIG"
        echo "Switched to amber mode"
        ;;
    *)
        # Toggle between modes
        if [ -z "$CURRENT_CLASS" ] || [ "$CURRENT_CLASS" = "" ]; then
            sed -i 's/class="[^"]*"/class="red-alert"/' "$WAYBAR_CONFIG"
            echo "RED ALERT: All hands to battle stations!"
        elif [ "$CURRENT_CLASS" = "red-alert" ]; then
            sed -i 's/class="[^"]*"/class="amber-mode"/' "$WAYBAR_CONFIG"
            echo "Switched to amber mode"
        else
            sed -i 's/class="[^"]*"/class=""/' "$WAYBAR_CONFIG"
            echo "Switched to normal mode"
        fi
        ;;
esac

# Restart Waybar to apply changes
killall waybar
waybar &
