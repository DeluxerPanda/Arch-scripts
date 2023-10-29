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
1. Asus-Linux.org stuff and lib32-vulkan-radeon
-------------------------------------------------------------------------"
sudo pacman -Syu --noconfirm --needed
fi
sudo cp /etc/pacman.conf /etc/pacman.conf.bak
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

message="Installing from Asus-Linux.org and lib32-vulkan-radeon"
message_length=${#message}
spaces=$(( (${#separator} - message_length) / 2 ))
printf "%s\n%${spaces}s%s\n%s\n" "$separator" "" "$message" "$separator"

message2="Asusctl, Supergfxctl, ROG Control Center, lib32-vulkan-radeon"
message2_length=${#message2}
spaces=$(( (${#separator} - message2_length) / 2 ))
 printf "%s%${spaces}s%s\n%s\n" "" "" "$message2" "$separator"

#Installing
sudo pacman -Sy --noconfirm --needed asusctl supergfxctl rog-control-center lib32-vulkan-radeon


#Asusctl - custom fan profiles, anime, led control etc
sudo systemctl enable --now power-profiles-daemon.service

#Supergfxctl - graphics switching
sudo systemctl enable --now supergfxd
