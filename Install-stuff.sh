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
1. Installing wget, git, libxft, libxinerama, xrandr, xwallpaper
2. Installing JetBrains Mono, Awesome Font
3. Make dwm, dmenu, st, slstatus work
4. Grub Theme
5. Asus-Linux.org stuff
-------------------------------------------------------------------------"
sudo pacman -Syu
fi

#Install necessary stuff

titel_message_length=${#titel_message}
spaces=$(( (${#separator} - message_length) / 2 ))
printf "%s\n%${spaces}s%s\n%s\n" "$separator" "" "$titel_message" ""

message="Installing necessary stuff"
message_length=${#message}
spaces=$(( (${#separator} - message_length) / 2 ))
printf "%s\n%${spaces}s%s\n%s\n" "$separator" "" "$message" "$separator"

message2="wget, git, libxft, libxinerama, xrandr, xwallpaper"
message2_length=${#message2}
spaces=$(( (${#separator} - message2_length) / 2 ))
 printf "%s%${spaces}s%s\n%s\n" "" "" "$message2" "$separator"

sudo pacman -Sy --noconfirm --needed wget git libxft libxinerama xorg-xrandr xwallpaper

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

message2="Makeing dwm, dmenu, st, slstatus work"
message2_length=${#message2}
spaces=$(( (${#separator} - message2_length) / 2 ))
 printf "%s%${spaces}s%s\n%s\n" "" "" "$message2" "$separator"

# Clone Git repository and move directories
git clone https://github.com/DeluxPanda/mydwm.git ~/.config/mydwm
cd ~/.config/mydwm

# Move directories and install applications
for app in "dwm" "dmenu" "st" "slstatus"; do
    sudo mv "$app" ~/.config/
    echo "Moving $app"
done

# Install applications
for app in "dwm" "dmenu" "st" "slstatus"; do
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

#Asus-Linux.org stuff

titel_message_length=${#titel_message}
spaces=$(( (${#separator} - message_length) / 2 ))
printf "%s\n%${spaces}s%s\n%s\n" "$separator" "" "$titel_message" ""

message="Adding repo from Asus-Linux.org"
message_length=${#message}
spaces=$(( (${#separator} - message_length) / 2 ))
printf "%s\n%${spaces}s%s\n%s\n" "$separator" "" "$message" "$separator"

#Add repo
sudo pacman-key --recv-keys 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
sudo pacman-key --finger 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
sudo pacman-key --lsign-key 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
sudo pacman-key --finger 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
wget "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x8b15a6b0e9a3fa35" -O g14.sec
sudo pacman-key -a g14.sec
sudo rm g14.sec
echo "[g14]
Server = https://arch.asus-linux.org" | sudo tee -a /etc/pacman.conf
sudo pacman -Suy


titel_message_length=${#titel_message}
spaces=$(( (${#separator} - message_length) / 2 ))
printf "%s\n%${spaces}s%s\n%s\n" "$separator" "" "$titel_message" ""

message="Installing from Asus-Linux.org"
message_length=${#message}
spaces=$(( (${#separator} - message_length) / 2 ))
printf "%s\n%${spaces}s%s\n%s\n" "$separator" "" "$message" "$separator"

message2="Asusctl, Supergfxctl, ROG Control Center"
message2_length=${#message2}
spaces=$(( (${#separator} - message2_length) / 2 ))
 printf "%s%${spaces}s%s\n%s\n" "" "" "$message2" "$separator"

#Installing
sudo pacman -Sy --noconfirm --needed asusctl supergfxctl rog-control-center

#Asusctl - custom fan profiles, anime, led control etc
sudo systemctl enable --now power-profiles-daemon.service

#Supergfxctl - graphics switching
sudo systemctl enable --now supergfxd

startx


