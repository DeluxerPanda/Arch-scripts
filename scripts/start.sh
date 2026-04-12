#!/bin/bash

# Arch Linux Installer Menu
# This script supports being run via curl | sh

echo "Arch Linux Installer Menu"
echo "1. Run Arch Installer from GitHub"
echo "2. Exit"
read -r -p "Choose an option: " choice < /dev/tty

case $choice in
    1)
        echo "Running Arch Installer..."
        curl -fsSL https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/refs/heads/autostart/Arch-install.sh | bash
        ;;
    2)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid option. Exiting..."
        exit 1
        ;;
esac