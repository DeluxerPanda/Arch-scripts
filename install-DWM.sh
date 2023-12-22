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
1. Installing wget, libxft, libxinerama, xrandr, xwallpaper, rofi, alsa-utils, base-devel
2. Installing JetBrains Mono, Awesome Font, pcmanfm, xarchiver, xorg-xinit, xcompmgr
3. Make dwm, st, slstatus work
4. Grub Theme
5. Installing YAY
6. Start DWM
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

message2="wget, libxft, libxinerama, xrandr, xwallpaper, rofi, alsa-utils, base-devel"
message2_length=${#message2}
spaces=$(( (${#separator} - message2_length) / 2 ))
 printf "%s%${spaces}s%s\n%s\n" "" "" "$message2" "$separator"

sudo pacman -S --noconfirm --needed wget git libxft libxinerama xorg-xrandr xwallpaper rofi alsa-utils base-devel

mkdir -p ~/Bilder/Wallpapers

mv wallpaper1.jpg ~/Bilder/Wallpapers

cp -f /etc/X11/xinit/xinitrc ~/.xinitrc

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

message2="JetBrains Mono, Awesome Font, pcmanfm, xarchiver"
message2_length=${#message2}
spaces=$(( (${#separator} - message2_length) / 2 ))
 printf "%s%${spaces}s%s\n%s\n" "" "" "$message2" "$separator"

sudo pacman -Sy --noconfirm --needed ttf-jetbrains-mono ttf-font-awesome pcmanfm xarchiver xorg-xinit xcompmgr

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
git clone https://github.com/DeluxerPanda/My-DWM.git ~/My-DWM
cd ~/My-DWM
mkdir -p ~/.config/suckless
# Move directories and install applications
for app in "dwm" "st" "slstatus"; do
    sudo mv "$app" ~/.config/suckless
    echo "Moving $app"
done

# Install applications
for app in "dwm" "st" "slstatus"; do
    cd ~/.config/suckless/"$app"
    echo "Installing $app"
    sudo make clean install
done
cd ~/
mv ~/My-DWM/.xinitrc ~/
# Remove the cloned repository
rm -rf ~/My-DWM

# Set up custom GRUB2 theme
sudo chown root:root CyberRe/*
THEME_DIR="/boot/grub/themes"
THEME_NAME="CyberRe"
sudo mkdir -p "${THEME_DIR}/${THEME_NAME}"
sudo cp -a "${THEME_NAME}"/* "${THEME_DIR}/${THEME_NAME}"
sudo cp -an /etc/default/grub /etc/default/grub.bak
sudo sed -i '/GRUB_THEME=/d' /etc/default/grub
echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" | sudo tee -a /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

#Installing YAY

titel_message_length=${#titel_message}
spaces=$(( (${#separator} - message_length) / 2 ))
printf "%s\n%${spaces}s%s\n%s\n" "$separator" "" "$titel_message" ""

message="Installing YAY"
message_length=${#message}
spaces=$(( (${#separator} - message_length) / 2 ))
printf "%s\n%${spaces}s%s\n%s\n" "$separator" "" "$message" "$separator"

message2="Makeing YAY work"
message2_length=${#message2}
spaces=$(( (${#separator} - message2_length) / 2 ))
 printf "%s%${spaces}s%s\n%s\n" "" "" "$message2" "$separator"
 
git clone https://aur.archlinux.org/yay.git ~/yay
cd ~/yay
makepkg -si -y
cd ~/
rm -rf ~/yay

rm -rf ~/yay

startx


