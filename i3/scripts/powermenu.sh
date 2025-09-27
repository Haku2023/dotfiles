#!/bin/bash

# Set your preferred rofi theme or options
# For a floating window, rofi is usually floating by default, but you can
# adjust its position and size.
MENU="Logout\nSuspend\nReboot\nShutdown\nExit i3"

# Add the theme string right into the command
chosen=$(echo -e "$MENU" | rofi -dmenu -i -p "See You Later ^^:" ) # Adjust font and size


#chosen=$(echo -e "$MENU" | rofi -dmenu -i -p "Power Menu:")

case "$chosen" in
    "Logout")
        i3-msg exit
        ;;
    "Suspend")
        systemctl suspend
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Shutdown")
        systemctl poweroff
        ;;
    "Exit i3")
        i3-msg exit
        ;;
    *)
        # Do nothing if nothing is chosen or cancelled
        ;;
esac
