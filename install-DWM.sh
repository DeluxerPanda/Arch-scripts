#!/bin/bash
titel_message="
 █████╗ ██████╗  ██████╗██╗  ██╗    ██████╗ ███████╗██╗     ██╗   ██╗██╗  ██╗
██╔══██╗██╔══██╗██╔════╝██║  ██║    ██╔══██╗██╔════╝██║     ██║   ██║╚██╗██╔╝
███████║██████╔╝██║     ███████║    ██║  ██║█████╗  ██║     ██║   ██║ ╚███╔╝
██╔══██║██╔══██╗██║     ██╔══██║    ██║  ██║██╔══╝  ██║     ██║   ██║ ██╔██╗
██║  ██║██║  ██║╚██████╗██║  ██║    ██████╔╝███████╗███████╗╚██████╔╝██╔╝ ██╗
╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝    ╚═════╝ ╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝
"
separator="-------------------------------------------------------------------------"

print_info_message() {
    print_message "$1"
}

if [ "$(id -u)" -eq 0 ]; then
clear
titel_message_length=${#titel_message}
spaces=$(( (${#separator} - message_length) / 2 ))
printf "%s\n%${spaces}s%s\n%s\n" "$separator" "" "$titel_message" ""

message="You can't run as root"
message_length=${#message}
spaces=$(( (${#separator} - message_length) / 2 ))
printf "%s\n%${spaces}s%s\n%s\n" "$separator" "" "$message" "$separator"

exit 1
else


titel_message_length=${#titel_message}
spaces=$(( (${#separator} - message_length) / 2 ))
printf "%s\n%${spaces}s%s\n%s\n" "$separator" "" "$titel_message" ""

message="Script starting"
message_length=${#message}
spaces=$(( (${#separator} - message_length) / 2 ))
printf "%s\n%${spaces}s%s\n%s\n" "$separator" "" "$message" "$separator"
echo -ne "
1. Installing wget, git, libxft, libxinerama, xrandr, xwallpaper, rofi, alsa-utils
2. Installing JetBrains Mono, Awesome Font
3. Make dwm, st, slstatus work
4. Grub Theme
5. Asus-Linux.org stuff
-------------------------------------------------------------------------"
sudo pacman -Syu --noconfirm --needed
fi

#Install necessary stuff

titel_message_length=${#titel_message}
spaces=$(( (${#separator} - message_length) / 2 ))
printf "%s\n%${spaces}s%s\n%s\n" "$separator" "" "$titel_message" ""

message="Installing necessary stuff"
message_length=${#message}
spaces=$(( (${#separator} - message_length) / 2 ))
printf "%s\n%${spaces}s%s\n%s\n" "$separator" "" "$message" "$separator"

message2="wget, git, libxft, libxinerama, xrandr, xwallpaper, rofi, alsa-utils"
message2_length=${#message2}
spaces=$(( (${#separator} - message2_length) / 2 ))
 printf "%s%${spaces}s%s\n%s\n" "" "" "$message2" "$separator"

sudo pacman -S --noconfirm --needed wget git libxft libxinerama xorg-xrandr xwallpaper rofi alsa-utils

mkdir -p ~/Bilder/Wallpapers

mv wallpaper1.jpg ~/Bilder/Wallpapers

cp /etc/X11/xinit/xinitrc ~/.xinitrc

echo "
xrandr --output eDP --scale 0.5x0.5
xwallpaper --zoom $HOME/Bilder/Wallpapers/wallpaper1.jpg
xcompmgr &
slstatus &
exec dwm
" | sudo tee -a ~/.xinitrc

#Install necessary stuff

titel_message_length=${#titel_message}
spaces=$(( (${#separator} - message_length) / 2 ))
printf "%s\n%${spaces}s%s\n%s\n" "$separator" "" "$titel_message" ""

message="Installing fonts"
message_length=${#message}
spaces=$(( (${#separator} - message_length) / 2 ))
printf "%s\n%${spaces}s%s\n%s\n" "$separator" "" "$message" "$separator"

message2="JetBrains Mono, Awesome Font"
message2_length=${#message2}
spaces=$(( (${#separator} - message2_length) / 2 ))
 printf "%s%${spaces}s%s\n%s\n" "" "" "$message2" "$separator"

sudo pacman -Sy --noconfirm --needed ttf-jetbrains-mono ttf-font-awesome

#Makeing dwm work

titel_message_length=${#titel_message}
spaces=$(( (${#separator} - message_length) / 2 ))
printf "%s\n%${spaces}s%s\n%s\n" "$separator" "" "$titel_message" ""

message="Makeing dwm work"
message_length=${#message}
spaces=$(( (${#separator} - message_length) / 2 ))
printf "%s\n%${spaces}s%s\n%s\n" "$separator" "" "$message" "$separator"

message2="Makeing dwm, st, slstatus work"
message2_length=${#message2}
spaces=$(( (${#separator} - message2_length) / 2 ))
 printf "%s%${spaces}s%s\n%s\n" "" "" "$message2" "$separator"

# Clone Git repository and move directories
git clone https://github.com/DeluxPanda/mydwm.git ~/.config/mydwm
cd ~/.config/mydwm

# Move directories and install applications
for app in "dwm" "st" "slstatus"; do
    sudo mv "$app" ~/.config/
    echo "Moving $app"
done

# Install applications
for app in "dwm" "st" "slstatus"; do
    cd ~/.config/"$app"
    echo "Installing $app"
    sudo make clean install
done
cd ~/
mv ~/.config/mydwm/.xinitrc ~/
# Remove the cloned repository
rm -rf ~/.config/mydwm

# Set up custom GRUB2 theme
sudo chmod root:root CyberRe/*
THEME_DIR="/boot/grub/themes"
THEME_NAME="CyberRe"
print_info_message "Setting up custom GRUB2 theme"
sudo mkdir -p "${THEME_DIR}/${THEME_NAME}"
sudo cp -a "${THEME_NAME}"/* "${THEME_DIR}/${THEME_NAME}"
sudo cp -an /etc/default/grub /etc/default/grub.bak
sudo sed -i '/GRUB_THEME=/d' /etc/default/grub
echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" | sudo tee -a /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

startx


