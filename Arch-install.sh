#!/bin/bash

# Redirect stdout and stderr to archsetup.txt and still output to console
exec > >(tee -i archsetup.txt)
exec 2>&1
export MSIBORD=$(cat /sys/class/dmi/id/board_vendor 2>/dev/null)
loadkeys sv-latin1
echo -ne "
-------------------------------------------------------------------------

 █████╗ ██████╗  ██████╗██╗  ██╗    ██████╗ ███████╗██╗     ██╗   ██╗██╗  ██╗
██╔══██╗██╔══██╗██╔════╝██║  ██║    ██╔══██╗██╔════╝██║     ██║   ██║╚██╗██╔╝
███████║██████╔╝██║     ███████║    ██║  ██║█████╗  ██║     ██║   ██║ ╚███╔╝ 
██╔══██║██╔══██╗██║     ██╔══██║    ██║  ██║██╔══╝  ██║     ██║   ██║ ██╔██╗ 
██║  ██║██║  ██║╚██████╗██║  ██║    ██████╔╝███████╗███████╗╚██████╔╝██╔╝ ██╗
╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝    ╚═════╝ ╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝
                                                                             
-------------------------------------------------------------------------
"
if [ ! -f /usr/bin/pacstrap ]; then
    echo "Det här skriptet måste köras från en Arch Linux ISO-miljö."
    exit 1
fi

root_check() {
    if [[ "$(id -u)" != "0" ]]; then
        echo -ne "FEL! Det här skriptet måste köras under användaren 'root'.!\n"
        exit 1
    fi
}

docker_check() {
    if awk -F/ '$2 == "docker"' /proc/self/cgroup | read -r; then
        echo -ne "FEL! Docker-containern stöds inte\n"
        exit 1
    elif [[ -f /.dockerenv ]]; then
        echo -ne "FEL! Docker-containern stöds inte\n"
        exit 1
    fi
}

arch_check() {
    if [[ ! -e /etc/arch-release ]]; then
        echo -ne "FEL! Det här skriptet måste köras i Arch Linux!\n"
        exit 1
    fi
}

pacman_check() {
    if [[ -f /var/lib/pacman/db.lck ]]; then
        echo "FEL! Pacman är blockerad."
        echo -ne "Om den inte körs ta bort /var/lib/pacman/db.lck.\n"
        exit 1
    fi
}

background_checks() {
    root_check
    arch_check
    pacman_check
    docker_check
}

select_option() {
    local options=("$@")
    local num_options=${#options[@]}
    local selected=0
    local last_selected=-1

    while true; do
        # Move cursor up to the start of the menu
        if [ $last_selected -ne -1 ]; then
            echo -ne "\033[${num_options}A"
        fi

        if [ $last_selected -eq -1 ]; then
            echo "Välj ett alternativ med piltangenterna och Enter:"
        fi
        for i in "${!options[@]}"; do
            if [ "$i" -eq $selected ]; then
                echo "> ${options[$i]}"
            else
                echo "  ${options[$i]}"
            fi
        done

        last_selected=$selected

        # Read user input
        read -rsn1 key < /dev/tty
        case $key in
            $'\x1b') # ESC sequence
                read -rsn2 -t 0.1 key < /dev/tty
                case $key in
                    '[A') # Up arrow
                        ((selected--))
                        if [ $selected -lt 0 ]; then
                            selected=$((num_options - 1))
                        fi
                        ;;
                    '[B') # Down arrow
                        ((selected++))
                        if [ $selected -ge $num_options ]; then
                            selected=0
                        fi
                        ;;
                esac
                ;;
            '') # Enter key
                break
                ;;
        esac
    done

    return $selected
}

# @description Displays ArchTitus logo
# @noargs
logo () {
# This will be shown on every set as user is progressing
echo -ne "
-------------------------------------------------------------------------

 █████╗ ██████╗  ██████╗██╗  ██╗    ██████╗ ███████╗██╗     ██╗   ██╗██╗  ██╗
██╔══██╗██╔══██╗██╔════╝██║  ██║    ██╔══██╗██╔════╝██║     ██║   ██║╚██╗██╔╝
███████║██████╔╝██║     ███████║    ██║  ██║█████╗  ██║     ██║   ██║ ╚███╔╝ 
██╔══██║██╔══██╗██║     ██╔══██║    ██║  ██║██╔══╝  ██║     ██║   ██║ ██╔██╗ 
██║  ██║██║  ██║╚██████╗██║  ██║    ██████╔╝███████╗███████╗╚██████╔╝██╔╝ ██╗
╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝    ╚═════╝ ╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝
                                                                                                                                                                     
-------------------------------------------------------------------------
"
}

# @description Disk selection for drive to be used with installation.
diskpart () {
echo -ne "
------------------------------------------------------------------------
    DETTA FORMATERAR OCH TAR BORT ALL DATA PÅ DISKEN 
    Se till att du vet vad du gör eftersom
    efter att du formaterat din disk finns det inget sätt att få tillbaka data 
    *****SÄKERHETSSKOPIERA DINA DATA INNAN DU FORTSÄTTER***** 
    ***JAG ÄR INTE ANSVARIG FÖR NÅGON DATAFÖRUST***
------------------------------------------------------------------------

"

    #Loop through selection if non-viable device (mmcblkXbootY, mmcblkXrpbm, etc) is selected
       while true
       do
       PS3='
       Välj vilken disk du vill installera på: '
       mapfile -t options < <(lsblk -n --output TYPE,KNAME,SIZE | awk '$1=="disk"{print "/dev/"$2"|"$3}')

       select_option "${options[@]}"
       disk=${options[$?]%|*}
       if [[ ! "${disk%|*}" =~  ^/dev/mmcblk[0-9]+[a-z]+[0-9]? ]]
          then
                break
          fi
          echo -e "\n${disk%|*} är inte en fungerande installationsenhet \n"
    done

    echo -e "\n${disk%|*} selected \n"
        export DISK=${disk%|*}
}

# @description Gather username and password to be used for installation.
userinfo () {
    # Loop through user input until the user gives a valid username
    while true
    do
            read -r -p "Ange användarnamn: " username < /dev/tty
            if [[ "${username,,}" =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$ ]]
            then
                    break
            fi
            echo "ogiltigt användarnamn."
    done
    export USERNAME=$username
    clear
    logo
    while true
    do
        echo "**OBS! Lösenordet kommer inte att visas när du skriver det, så var noga med att skriva det korrekt.**"
        echo "**OBS! Använd inte numpadstangenterna just nu!**"
        read -rs -p "Ange lösenord: " PASSWORD1 < /dev/tty
        echo -ne "\n"
        read -rs -p "Ange lösenord igen: " PASSWORD2 < /dev/tty
        echo -ne "\n"
        if [[ "$PASSWORD1" == "$PASSWORD2" ]]; then
            break
        else
            echo -ne "FEL! Lösenorden matchar inte. \n"
        fi
    done
    export PASSWORD=$PASSWORD1
    clear
    logo
     # Loop through user input until the user gives a valid hostname, but allow the user to force save
    while true
    do
            read -r -p "Namnge din dator: " name_of_machine < /dev/tty
            # hostname regex (!!couldn't find spec for computer name!!)
            if [[ "${name_of_machine,,}" =~ ^[a-z][a-z0-9_.-]{0,62}[a-z0-9]$ ]]
            then
                    break
            fi
            # if validation fails allow the user to force saving of the hostname
            read -r -p "namnet verkar inte vara korrekt. Vill du fortfarande använda det?? (y/n)" force < /dev/tty
            if [[ "${force,,}" = "y" ]]
            then
                    break
            fi
    done
    export NAME_OF_MACHINE=$name_of_machine
}

setupEnv () {
        echo -ne "  
    -----------------------------------------------------------------------
                        Välj Environment                    
    -----------------------------------------------------------------------
    1) Kde plasma (rekommenderas)
    2) DWM (för avancerade användare)
    -----------------------------------------------------------------------
    "
    options=("Kde plasma (rekommenderas)" "DWM (för avancerade användare)")
    select_option "${options[@]}"
    case $? in
        0)
        export ENV="Env_Kde";;
        1)
        export ENV="Env_DWM";;
        *) echo "Fel alternativ. Försök igen."; setupEnv;;
    esac 
}

setupFastfetch () {
        echo -ne "  
    -----------------------------------------------------------------------
                        Välj ett Fastfetch tema                    
    -----------------------------------------------------------------------
    1) Transgender Flagga
    2) Non-binary Flagga
    3) inget tema
    -----------------------------------------------------------------------
    "
    options=("Transgender Flag" "Nonbinary Flag" "inget tema")
    select_option "${options[@]}"

    case $? in
        0)
        export STARSHIP_FASTFETCH="FASTFETCH_TRANSGENDER_FLAGGA";;
        1)
        export STARSHIP_FASTFETCH="FASTFETCH_NON-BINARY-FLAGGA";;
        2) 
        export STARSHIP_FASTFETCH="none";;
        *) echo "Fel alternativ. Försök igen."; setupFastfetch;;
    esac
}

setupStarship () {
        echo -ne "  
    -----------------------------------------------------------------------
                        Välj ett Starship tema                    
    -----------------------------------------------------------------------
    1) Transgender
    2) Non-binary
    3) inget tema
    -----------------------------------------------------------------------
    "
    options=("Transgender Flag" "Nonbinary Flag" "inget tema")
    select_option "${options[@]}"
    case $? in
        0)
        export STARSHIP_TEMA="StarshipTema_TRANSGENDER";;
        1)
        export STARSHIP_TEMA="StarshipTema_NON-BINARY";;
        2) 
        export STARSHIP_TEMA="none";;
        *) echo "Fel alternativ. Försök igen."; setupStarship;;
    esac
}

setupStarshipEmoji () {
    clear
        echo -ne "  
    -----------------------------------------------------------------------
                        Välj ett Starship Emoji                    
    -----------------------------------------------------------------------
    "
    options=("🐼 [Panda] (Standard)" "😺 [Katt]" "🐧 [Pingvin]" "🦄 [Enhörning]" "🦊 [Räv]" "🦉 [Ugla]" "🐝 [bi]" "🍍 [Ananas]")
    select_option "${options[@]}"

    case $? in
        0)
        export STARSHIP_EMOJI="StarshipEmoji_PANDA";;
        1)
        export STARSHIP_EMOJI="StarshipEmoji_kATT";;
        2) 
        export STARSHIP_EMOJI="StarshipEmoji_PINGVIN";;
        3) 
        export STARSHIP_EMOJI="StarshipEmoji_ENHÖRNING";;
        4) 
        export STARSHIP_EMOJI="StarshipEmoji_RÄV";;
        5) 
        export STARSHIP_EMOJI="StarshipEmoji_UGLA";;
        6) 
        export STARSHIP_EMOJI="StarshipEmoji_BI";;
        7) 
        export STARSHIP_EMOJI="StarshipEmoji_ANNANAS";;
        8)
        export STARSHIP_TEMA="none";;
        *) echo "Fel alternativ. Försök igen."; setupStarshipEmoji;;
    esac
}

setupGrub () {
    echo -ne "  
    -----------------------------------------------------------------------
                        Välj ett grub tema                    
    -----------------------------------------------------------------------
    1) Cartoon Girl
    2) Aesthetic
    3) Fallout
    4) Stardew Valley
    5) inget tema
    -----------------------------------------------------------------------
    "
    options=("Cartoon Girl" "Aesthetic" "Fallout" "Stardew Valley" "inget tema")
    select_option "${options[@]}"
    case $? in
        0)
            export GRUBTHEME="CartoonGirl";;
        1)
            export GRUBTHEME="Aesthetic";;
        2)
            export GRUBTHEME="fallout";;
        3)
            export GRUBTHEME="StardewValley";;
        4)
            export GRUBTHEME="none";;
        *) echo "Fel alternativ. Försök igen."; setupGrub;;
    esac
}

dualGPU_check () {
    if lspci | grep -E "NVIDIA|GeForce" >/dev/null && lspci | grep -E "Radeon" >/dev/null; then
        echo -ne "  
    -----------------------------------------------------------------------
                        Välj huvud GPU                    
    -----------------------------------------------------------------------
    1) Radeon (AMD)
    2) NVIDIA
    -----------------------------------------------------------------------
    "
    options=("Radeon (AMD)" "NVIDIA")
    select_option "${options[@]}"
    case $? in
        0)
        export DUALGPU="AMD";;
        1)
        export DUALGPU="NVIDIA";;
        *) echo "Fel alternativ. Försök igen."; dualGPU_check;;
    esac 
    fi
}


# Starting functions
background_checks
clear
logo
userinfo
clear
logo
setupEnv
clear
logo
setupFastfetch
clear
logo
setupStarship
clear
logo
setupStarshipEmoji
clear
logo
setupGrub
clear
logo
dualGPU_check
clear
logo
diskpart
clear
logo


timedatectl set-ntp true
pacman -Sy
pacman -S --noconfirm archlinux-keyring #update keyrings to latest to prevent packages failing to install
pacman -S --noconfirm --needed pacman-contrib
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
pacman -S --noconfirm --needed rsync grub

if [ ! -d "/mnt" ]; then
    mkdir /mnt
fi

pacman -S --noconfirm --needed gptfdisk btrfs-progs glibc
echo -ne "
-------------------------------------------------------------------------
                    Formaterar disk
-------------------------------------------------------------------------
"
umount -A --recursive /mnt # make sure everything is unmounted before we start
# disk prep
sgdisk -Z "${DISK}" # zap all on disk
sgdisk -a 2048 -o "${DISK}" # new gpt disk 2048 alignment

# create partitions
sgdisk -n 1::+1M --typecode=1:ef02 --change-name=1:'BIOSBOOT' "${DISK}" # partition 1 (BIOS Boot Partition)
sgdisk -n 2::+1GiB --typecode=2:ef00 --change-name=2:'EFIBOOT' "${DISK}" # partition 2 (UEFI Boot Partition)
sgdisk -n 3::-0 --typecode=3:8300 --change-name=3:'ROOT' "${DISK}" # partition 3 (Root), default start, remaining
if [[ ! -d "/sys/firmware/efi" ]]; then # Checking for bios system
    sgdisk -A 1:set:2 "${DISK}"
fi
partprobe "${DISK}" # reread partition table to ensure it is correct

# make filesystems
echo -ne "
-------------------------------------------------------------------------
                    Skapar filsystem
-------------------------------------------------------------------------
"
# @description Creates the btrfs subvolumes.
createsubvolumes () {
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    # Set @ as the default subvolume so genfstab records subvolid=256 (not 5)
    # Path form requires btrfs-progs >= 5.6 (standard on Arch rolling)
    btrfs subvolume set-default /mnt/@
}

# @description Mount all btrfs subvolumes after root has been mounted.
mountallsubvol () {
    mount -o noatime,compress=zstd,ssd,commit=120,subvol=@home "${partition3}" /mnt/home
}

# @description BTRFS subvolulme creation and mounting.
subvolumesetup () {
# create nonroot subvolumes
    createsubvolumes
# unmount root to remount with subvolume
    umount /mnt
# mount @ subvolume
    mount -o noatime,compress=zstd,ssd,commit=120,subvol=@ "${partition3}" /mnt
# make directories home, .snapshots, var, tmp
    mkdir -p /mnt/home
# mount subvolumes
    mountallsubvol
}

if [[ "${DISK}" =~ "nvme"|"mmcblk" ]]; then
    partition2=${DISK}p2
    partition3=${DISK}p3
else
    partition2=${DISK}2
    partition3=${DISK}3
fi

    mkfs.fat -F32 -n "EFIBOOT" "${partition2}"
    mkfs.btrfs -f "${partition3}"
    mount -t btrfs "${partition3}" /mnt
    subvolumesetup

BOOT_UUID=$(blkid -s UUID -o value "${partition2}")

sync
if ! mountpoint -q /mnt; then
    echo "FEL! Misslyckades med att montera ${partition3} till /mnt efter flera försök."
    exit 1
fi
mkdir -p /mnt/boot
mount -U "${BOOT_UUID}" /mnt/boot/

if ! grep -qs '/mnt' /proc/mounts; then
    echo "Enheten är inte monterad, kan inte fortsätta"
    echo "Omstart på 3 sekunder ..." && sleep 1
    echo "Omstart på 2 sekunder..." && sleep 1
    echo "Omstart på 1 sekunder ..." && sleep 1
    reboot now
fi

if [[ ! -d "/sys/firmware/efi" ]]; then
    pacstrap /mnt base base-devel linux linux-headers linux-firmware btrfs-progs --noconfirm --needed
else
    pacstrap /mnt base base-devel linux linux-headers linux-firmware efibootmgr btrfs-progs --noconfirm --needed
fi
echo "keyserver hkp://keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist

genfstab -U /mnt >> /mnt/etc/fstab
echo "
  Generated /etc/fstab:
"
cat /mnt/etc/fstab
echo -ne "
-------------------------------------------------------------------------
                    GRUB BIOS Bootloader Installation
-------------------------------------------------------------------------
"
if [[ ! -d "/sys/firmware/efi" ]]; then
    grub-install --boot-directory=/mnt/boot "${DISK}" --removable
fi

gpu_type=$(lspci | grep -E "VGA|3D|Display")

arch-chroot /mnt /bin/bash <<EOF

echo -ne "
-------------------------------------------------------------------------
                     Nätverksinställningar
-------------------------------------------------------------------------
"
pacman -S --noconfirm --needed networkmanager
systemctl enable NetworkManager

pacman -S --noconfirm --needed pacman-contrib curl terminus-font
pacman -S --noconfirm --needed rsync grub arch-install-scripts git ntp wget

NUM_CORES=$(nproc)
sed -i "s/#MAKEFLAGS=\"-j\"/MAKEFLAGS=\"-j$NUM_CORES\"/g" /etc/makepkg.conf
sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $NUM_CORES -z -)/g" /etc/makepkg.conf

echo -ne "
-------------------------------------------------------------------------
                     Sätter upp språk
-------------------------------------------------------------------------
"

# Enable locales
sed -i 's/^#sv_SE.UTF-8 UTF-8/sv_SE.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen

# Time & locale
timedatectl --no-ask-password set-timezone Europe/Stockholm
timedatectl --no-ask-password set-ntp true
localectl --no-ask-password set-locale LANG=sv_SE.UTF-8 LC_TIME=sv_SE.UTF-8
ln -sf /usr/share/zoneinfo/Europe/Stockholm /etc/localtime

# Console keyboard
loadkeys sv-latin1
echo "KEYMAP=sv-latin1" > /etc/vconsole.conf

# System locale
echo "LANG=sv_SE.UTF-8" > /etc/locale.conf
echo "LC_TIME=sv_SE.UTF-8" >> /etc/locale.conf

# Global environmental variables
echo "LANG=sv_SE.UTF-8" > /etc/environment
echo "LC_ALL=sv_SE.UTF-8" >> /etc/environment

# X11 keyboard layout
mkdir -p /etc/X11/xorg.conf.d
echo 'Section "InputClass"' > /etc/X11/xorg.conf.d/00-keyboard.conf
echo '    Identifier "system-keyboard"' >> /etc/X11/xorg.conf.d/00-keyboard.conf
echo '    MatchIsKeyboard "on"' >> /etc/X11/xorg.conf.d/00-keyboard.conf
echo '    Option "XkbLayout" "se"' >> /etc/X11/xorg.conf.d/00-keyboard.conf
echo 'EndSection' >> /etc/X11/xorg.conf.d/00-keyboard.conf

# SDDM locale
mkdir -p /etc/sddm.conf.d
echo '[General]' > /etc/sddm.conf.d/locale.conf
echo 'InputMethod=' >> /etc/sddm.conf.d/locale.conf
echo '' >> /etc/sddm.conf.d/locale.conf
echo '[Locale]' >> /etc/sddm.conf.d/locale.conf
echo 'Lang=sv_SE.UTF-8' >> /etc/sddm.conf.d/locale.conf

# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

# Add parallel downloading
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

# Set colors and enable the easter egg
sed -i 's/^#Color/Color\nILoveCandy/' /etc/pacman.conf

# Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm --needed


echo -ne "
-------------------------------------------------------------------------
                     Installerar Microcode
-------------------------------------------------------------------------
"

# determine processor type and install microcode
if grep -q "GenuineIntel" /proc/cpuinfo; then
    echo "Installing Intel microcode"
    pacman -S --noconfirm --needed intel-ucode
elif grep -q "AuthenticAMD" /proc/cpuinfo; then
    echo "Installing AMD microcode"
    pacman -S --noconfirm --needed amd-ucode
else
    echo "Unable to determine CPU vendor. Skipping microcode installation."
fi

echo -ne "
-------------------------------------------------------------------------
                     Installera grafikdrivrutiner
-------------------------------------------------------------------------
"

# Graphics Drivers find and install
if [[ "$DUALGPU" == "AMD" ]]; then
    echo "Installing AMD drivers: xf86-video-amdgpu vulkan-radeon"
    pacman -S --noconfirm --needed xf86-video-amdgpu vulkan-radeon
    mkdir -p /etc/X11/xorg.conf.d/
    wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/main/config/X11/20-amdgpu.conf -O /etc/X11/xorg.conf.d/20-amdgpu.conf
elif echo "${gpu_type}" | grep -E "NVIDIA|GeForce"; then
    echo "Installing NVIDIA drivers: nvidia-open nvidia-open-dkms nvidia-settings nvidia-utils"
    pacman -S --noconfirm --needed nvidia-open nvidia-open-dkms nvidia-settings nvidia-utils
elif echo "${gpu_type}" | grep 'VGA' | grep -E "Radeon"; then
    echo "Installing AMD drivers: xf86-video-amdgpu vulkan-radeon"
    pacman -S --noconfirm --needed xf86-video-amdgpu vulkan-radeon
    mkdir -p /etc/X11/xorg.conf.d/
    wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/main/config/X11/20-amdgpu.conf -O /etc/X11/xorg.conf.d/20-amdgpu.conf
fi

echo -ne "
-------------------------------------------------------------------------
                     Lägger till användare
-------------------------------------------------------------------------
"

groupadd libvirt
groupadd kvm
groupadd plugdev
groupadd docker
useradd -m -G wheel,libvirt,kvm,plugdev,docker -s /bin/bash $USERNAME
echo "$USERNAME created, home directory created, added to wheel and libvirt and kvm and plugdev and docker group, default shell set to /bin/bash"
echo "$USERNAME:$PASSWORD" | chpasswd
echo "$USERNAME password set"
echo $NAME_OF_MACHINE > /etc/hostname

echo -ne "
-------------------------------------------------------------------------
                     setup Environment
-------------------------------------------------------------------------
"

touch /etc/sddm.conf
touch /etc/sddm.conf.d/10-wayland.conf

pacman -S --noconfirm --needed bash-completion nfs-utils usbutils nano bat ffmpeg btop gnome-keyring fuse pipewire pipewire-pulse pipewire-alsa dunst starship fastfetch
pacman -S --noconfirm --needed pavucontrol sddm kdeconnect flatpak
pacman -S --noconfirm --needed steam gamescope prismlauncher
pacman -S --noconfirm --needed ttf-jetbrains-mono-nerd noto-fonts-emoji qt5ct qt6ct
pacman -S --noconfirm --needed unrar unzip zip xdg-user-dirs ffmpeg

wget https://github.com/DeluxerPanda/Arch-scripts/raw/refs/heads/main/theme/catppuccin-frappe-pink-sddm.tar.gz -O /usr/share/sddm/themes/catppuccin-frappe-pink-sddm.tar.gz
tar -xvzf /usr/share/sddm/themes/catppuccin-frappe-pink-sddm.tar.gz -C /usr/share/sddm/themes/
rm /usr/share/sddm/themes/catppuccin-frappe-pink-sddm.tar.gz



echo '[Theme]' >> /etc/sddm.conf
echo 'Current=catppuccin-frappe-pink' >> /etc/sddm.conf

echo '[General]' >> /etc/sddm.conf.d/10-wayland.conf
echo 'DisplayServer=wayland' >> /etc/sddm.conf.d/10-wayland.conf

if lsusb | grep -q "Razer"; then
    sudo pacman -S --noconfirm --needed openrazer-daemon
fi

mkdir -p /home/$USERNAME
chown $USERNAME:$USERNAME /home/$USERNAME

runuser -l "$USERNAME" -c 'LC_ALL=sv_SE.UTF-8 xdg-user-dirs-update --force'

runuser -l "$USERNAME" -c '

cd /home/$USERNAME
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg --noconfirm -si
cd ..
rm -rf yay
yay -S --sudoloop --noconfirm --needed librewolf-bin

if lsusb | grep -q "Razer"; then
    yay -S --sudoloop --noconfirm --needed razergenie
fi

if lsusb | grep -q "GoXLRMini"; then
    yay -S --sudoloop --noconfirm --needed goxlr-utility
    
    mkdir -p /home/$USERNAME/.config

    mkdir -p /home/$USERNAME/.config/autostart

    wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/main/scripts/GoXLR_loopback.sh -O /home/$USERNAME/.config/autostart/GoXLR_loopback.sh
    wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/main/config/autostart/GoXLR_loopback.desktop -O /home/$USERNAME/.config/autostart/GoXLR_loopback.desktop
    wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/main/config/autostart/GoXLR_daemon.desktop -O /home/$USERNAME/.config/autostart/GoXLR_daemon.desktop

    chmod +x /home/$USERNAME/.config/autostart/GoXLR_loopback.sh
    chmod 600 /home/$USERNAME/.config/autostart/GoXLR_loopback.desktop
    chmod 600 /home/$USERNAME/.config/autostart/GoXLR_daemon.desktop

    sed -i "s|^Exec=.*|Exec=/home/$USERNAME/.config/autostart/GoXLR_loopback.sh|" \
    "/home/$USERNAME/.config/autostart/GoXLR_loopback.desktop"


    wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/main/config/GoXLR/profiles/Default.goxlr -O /home/$USERNAME/Skrivbord/Default.goxlr
    wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/main/config/GoXLR/mic-profiles/DEFAULT.goxlrMicProfile -O /home/$USERNAME/Skrivbord/DEFAULT.goxlrMicProfile
    
    chown $USERNAME:$USERNAME /home/$USERNAME/Skrivbord/Default.goxlr
    chown $USERNAME:$USERNAME /home/$USERNAME/Skrivbord/DEFAULT.goxlrMicProfile
fi

wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/refs/heads/main/config/.bashrc -O /home/$USERNAME/.bashrc

    mkdir -p /home/$USERNAME/.config/fastfetch

if [[ "$STARSHIP_FASTFETCH" == "FASTFETCH_TRANSGENDER_FLAGGA" ]]; then
        wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/main/config/fastfetch/transgender/config.jsonc -O /home/$USERNAME/.config/fastfetch/config.jsonc
        wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/main/config/fastfetch/transgender/trans.txt -O /home/$USERNAME/.config/fastfetch/trans.txt
elif [[ "$STARSHIP_FASTFETCH" == "FASTFETCH_NON-BINARY-FLAGGA" ]]; then
        wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/main/config/fastfetch/nonbinary/config.jsonc -O /home/$USERNAME/.config/fastfetch/config.jsonc
        wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/main/config/fastfetch/nonbinary/nonbinary.txt -O /home/$USERNAME/.config/fastfetch/nonbinary.txt
fi

if [[ "$STARSHIP_TEMA" == "StarshipTema_TRANSGENDER" ]]; then
        wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/main/config/starship/transgender/starship.toml -O /home/$USERNAME/.config/starship.toml
elif [[ "$STARSHIP_TEMA" == "StarshipTema_NON-BINARY" ]]; then
        wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/main/config/starship/nonbinary/starship.toml -O /home/$USERNAME/.config/starship.toml
fi
'
echo -ne "
-------------------------------------------------------------------------
                       Starship Emoji
-------------------------------------------------------------------------
"

if [[ "$STARSHIP_EMOJI" == "StarshipEmoji_PANDA" ]]; then
        sed -i "s|format = '\[[^]]*\](\$style)'|format = '[🐼](\$style)'|" "/home/$USERNAME/.config/starship.toml"
elif [[ "$STARSHIP_EMOJI" == "StarshipEmoji_kATT" ]]; then
        sed -i "s|format = '\[[^]]*\](\$style)'|format = '[😺](\$style)'|" "/home/$USERNAME/.config/starship.toml"
elif [[ "$STARSHIP_EMOJI" == "StarshipEmoji_PINGVIN" ]]; then
        sed -i "s|format = '\[[^]]*\](\$style)'|format = '[🐧](\$style)'|" "/home/$USERNAME/.config/starship.toml"
elif [[ "$STARSHIP_EMOJI" == "StarshipEmoji_ENHÖRNInG" ]]; then
        sed -i "s|format = '\[[^]]*\](\$style)'|format = '[🦄](\$style)'|" "/home/$USERNAME/.config/starship.toml"
elif [[ "$STARSHIP_EMOJI" == "StarshipEmoji_RÄV" ]]; then
        sed -i "s|format = '\[[^]]*\](\$style)'|format = '[🦊](\$style)'|" "/home/$USERNAME/.config/starship.toml"
elif [[ "$STARSHIP_EMOJI" == "StarshipEmoji_UGLA" ]]; then
        sed -i "s|format = '\[[^]]*\](\$style)'|format = '[🦉](\$style)'|" "/home/$USERNAME/.config/starship.toml"
elif [[ "$STARSHIP_EMOJI" == "StarshipEmoji_BI" ]]; then
        sed -i "s|format = '\[[^]]*\](\$style)'|format = '[🐝](\$style)'|" "/home/$USERNAME/.config/starship.toml"
elif [[ "$STARSHIP_EMOJI" == "StarshipEmoji_ANNANAS" ]]; then
        sed -i "s|format = '\[[^]]*\](\$style)'|format = '[🍍](\$style)'|" "/home/$USERNAME/.config/starship.toml"
fi

if [[ "$ENV" == "Env_DWM" ]]; then
echo -ne "
-------------------------------------------------------------------------
                     DWM
-------------------------------------------------------------------------
"
    pacman -S --noconfirm --needed libx11 libxft xorg-server xorg-xinit xorg-xset network-manager-applet mate-polkit numlockx archlinux-xdg-menu xclip

    pacman -S --needed --noconfirm rofi arandr xarchiver mpv feh flameshot nwg-look papirus-icon-theme pcmanfm-qt gvfs-smb code

runuser -l "$USERNAME" -c "
cd /home/$USERNAME
    git clone https://github.com/DeluxerPanda/dwm.git
    cd dwm
    sudo make clean install
    cd ..
    rm -rf dwm

    git clone https://github.com/DeluxerPanda/st.git
    cd st
    sudo make clean install
    cd ..
    rm -rf st

    mkdir -p /home/$USERNAME/Bilder/backgrounds
    wget -O /home/$USERNAME/Bilder/backgrounds/wallpaper.jpg "https://lh3.googleusercontent.com/pw/AP1GczNr22gSNbdSNq_08trKdHkkswDq1k2PuefBqriaPp86lshFr10RjFqKQ_phn0187riksWgh-ouqn_6-MkHwVb5nIpyCaiH34WCOIywCis8X39gV3q3Fsy_9HZO-he7gxYnjbt7zulTazkiIj4qxyBjY"

    mkdir -p /home/$USERNAME/.config/rofi
    wget -O /home/$USERNAME/.config/rofi/config.rasi "https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/main/config/rofi/config.rasi"
    mkdir -p /home/$USERNAME/.config/rofi/themes
    wget -O /home/$USERNAME/.config/rofi/themes/catppuccin-mocha.rasi "https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/main/config/rofi/themes/catppuccin-mocha.rasi"

    xdg-settings set default-web-browser librewolf.desktop
    xdg-mime default librewolf.desktop application/pdf
    xdg-mime default feh.desktop image/jpeg
    xdg-mime default feh.desktop image/png
    xdg-mime default feh.desktop image/webp
    xdg-mime default feh.desktop image/gif
    xdg-mime default mpv.desktop video/webm
    xdg-mime default mpv.desktop video/mp4
    xdg-mime default mpv.desktop video/quicktime
    xdg-mime default mpv.desktop video/x-matroska
    xdg-mime default mpv.desktop video/x-matroska
    xdg-mime default xarchiver.desktop application/zip
    xdg-mime default xarchiver.desktop application/x-tar
    xdg-mime default xarchiver.desktop application/x-gzip
    xdg-mime default xarchiver.desktop application/x-bzip2
    xdg-mime default xarchiver.desktop application/x-xz
    xdg-mime default xarchiver.desktop application/x-7z-compressed
    xdg-mime default xarchiver.desktop application/x-rar
    xdg-mime default xarchiver.desktop application/x-compressed-tar
    xdg-mime default xarchiver.desktop application/x-xz-compressed
    xdg-mime default code.desktop text/html
    xdg-mime default code.desktop text/plain
    xdg-mime default code.desktop text/xml
    xdg-mime default code.desktop text/css
    xdg-mime default code.desktop text/csv
    xdg-mime default code.desktop text/markdown
    xdg-mime default code.desktop text/x-python
    xdg-mime default code.desktop text/x-shellscript
    xdg-mime default code.desktop text/x-csrc
    xdg-mime default code.desktop text/x-c++src
    xdg-mime default code.desktop text/x-javascript
    xdg-mime default code.desktop application/json
    xdg-mime default code.desktop application/javascript
    xdg-mime default code.desktop application/xml
    xdg-mime default code.desktop application/x-yaml    

    touch /etc/environment
    echo "QT_QPA_PLATFORMTHEME=qt6ct" >> /etc/environment
    echo "GTK_THEME=Adwaita:dark" >> /etc/environment

    mkdir -p /home/$USERNAME/.config/qt6ct/colors/
    mkdir -p /home/$USERNAME/.config/qt5ct/colors/
    wget https://github.com/DeluxerPanda/Arch-scripts/raw/refs/heads/main/theme/catppuccin-frappe-pink-qt.conf -O /home/$USERNAME/.config/qt6ct/colors/catppuccin-frappe-pink-qt.conf
    wget https://github.com/DeluxerPanda/Arch-scripts/raw/refs/heads/main/theme/catppuccin-frappe-pink-qt.conf -O /home/$USERNAME/.config/qt5ct/colors/catppuccin-frappe-pink-qt.conf

    mkdir -p /home/$USERNAME/.themes
    wget https://github.com/DeluxerPanda/Arch-scripts/raw/refs/heads/main/theme/Catppuccin-Frappe-Standard-Pink-Dark-gtk.tar.gz -O /home/$USERNAME/.themes/Catppuccin-Frappe-Standard-Pink-Dark-gtk.tar.gz
    tar -xvzf /home/$USERNAME/.themes/Catppuccin-Frappe-Standard-Pink-Dark-gtk.tar.gz -C /home/$USERNAME/.themes/
    rm /home/$USERNAME/.themes/Catppuccin-Frappe-Standard-Pink-Dark-gtk.tar.gz

    mkdir -p /home/$USERNAME/.icons
    wget https://github.com/DeluxerPanda/Arch-scripts/raw/refs/heads/main/theme/catppuccin-frappe-pink-cursors.tar.gz -O /home/$USERNAME/.icons/catppuccin-frappe-pink-cursors.tar.gz
    tar -xvzf /home/$USERNAME/.icons/catppuccin-frappe-pink-cursors.tar.gz -C /home/$USERNAME/.icons/
    rm /home/$USERNAME/.icons/catppuccin-frappe-pink-cursors.tar.gz


"
fi

if [[ "$ENV" == "Env_Kde" ]]; then
echo -ne "
-------------------------------------------------------------------------
                     KDE Plasma
-------------------------------------------------------------------------
"
sudo pacman -S --needed --noconfirm plasma konsole kate gwenview ark dolphin
pacman -S --noconfirm --needed sddm-kcm vlc
fi

echo -ne "
-------------------------------------------------------------------------
               Skapa Grub-startmenyn
-------------------------------------------------------------------------
"

# Final Setup and Configurations
# GRUB EFI Bootloader Install & Check

if [[ -d "/sys/firmware/efi" ]]; then
    grub-install --efi-directory=/boot ${DISK} --removable
fi

# set kernel parameter for adding splash screen
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& splash /' /etc/default/grub

# remove quiet from grub cmdline
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)quiet\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1\2"/' /etc/default/grub

sed -i '/^GRUB_TIMEOUT=/c\GRUB_TIMEOUT=30' /etc/default/grub



if [[ "$GRUBTHEME" == "CartoonGirl" ]]; then
        mkdir -p "/boot/grub/themes/CartoonGirl"
        wget https://github.com/DeluxerPanda/Arch-scripts/raw/refs/heads/main/config/Grub/CartoonGirl.tar.gz -O /boot/grub/themes/CartoonGirl.tar.gz
        tar --no-same-owner -xzf /boot/grub/themes/CartoonGirl.tar.gz -C /boot/grub/themes/CartoonGirl --strip-components=1
        rm /boot/grub/themes/CartoonGirl.tar.gz
        sed -i 's|^#\?GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/CartoonGirl/theme.txt"|' /etc/default/grub
elif [[ "$GRUBTHEME" == "Aesthetic" ]]; then
        mkdir -p "/boot/grub/themes/Aesthetic"
        wget https://github.com/DeluxerPanda/Arch-scripts/raw/refs/heads/main/config/Grub/Aesthetic.tar.gz -O /boot/grub/themes/Aesthetic.tar.gz
        tar --no-same-owner -xzf /boot/grub/themes/Aesthetic.tar.gz -C /boot/grub/themes/Aesthetic --strip-components=1
        rm /boot/grub/themes/Aesthetic.tar.gz
        sed -i 's|^#\?GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/Aesthetic/theme.txt"|' /etc/default/grub
elif [[ "$GRUBTHEME" == "fallout" ]]; then
        mkdir -p "/boot/grub/themes/fallout"
        wget https://github.com/DeluxerPanda/Arch-scripts/raw/refs/heads/main/config/Grub/fallout.tar.gz -O /boot/grub/themes/fallout.tar.gz
        tar --no-same-owner -xzf /boot/grub/themes/fallout.tar.gz -C /boot/grub/themes/fallout --strip-components=1
        rm /boot/grub/themes/fallout.tar.gz
        sed -i 's|^#\?GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/fallout/theme.txt"|' /etc/default/grub
elif [[ "$GRUBTHEME" == "StardewValley" ]]; then
        mkdir -p "/boot/grub/themes/StardewValley"
        wget https://github.com/DeluxerPanda/Arch-scripts/raw/refs/heads/main/config/Grub/StardewValley.tar.gz -O /boot/grub/themes/StardewValley.tar.gz
        tar --no-same-owner -xzf /boot/grub/themes/StardewValley.tar.gz -C /boot/grub/themes/StardewValley --strip-components=1
        rm /boot/grub/themes/StardewValley.tar.gz
        sed -i 's|^#\?GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/StardewValley/theme.txt"|' /etc/default/grub
fi


echo -e "Updating grub..."

    grub-mkconfig -o /boot/grub/grub.cfg

    mkinitcpio -P

if [[ "$MSIBORD" == *"MSI"* || "$MSIBORD" == *"Micro-Star"* ]]; then
    mkdir -p /boot/EFI/Microsoft/Boot/
    cp /boot/EFI/BOOT/BOOTX64.EFI /boot/EFI/Microsoft/Boot/bootmgfw.efi
fi

    echo -e "All set!"


echo -ne "
-------------------------------------------------------------------------
                     Aktivera viktiga tjänster
-------------------------------------------------------------------------
"

ntpd -qg
systemctl enable ntpd.service
echo "  NTP enabled"
systemctl disable dhcpcd.service
echo "  DHCP disabled"
systemctl enable NetworkManager.service
echo "  NetworkManager enabled"
systemctl enable sddm.service
echo "  sddm enabled"

if lsusb | grep -q "Razer"; then
    sudo systemctl enable openrazer-daemon
    echo "  openrazer enabled"
fi

echo -ne "
-------------------------------------------------------------------------
                     Städa upp
-------------------------------------------------------------------------
"

# Remove no password sudo rights
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
EOF
clear
logo
echo -ne "
                     Installation klar!

Du kan nu starta om datorn och logga in på ditt nya Arch Linux-system!
-------------------------------------------------------------------------
"
