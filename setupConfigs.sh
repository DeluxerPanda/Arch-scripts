#!/bin/bash

work_dir="$(pwd)"

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
            echo "Välj ett alternativ med piltangenterna och tryck på Enter:"
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
        read -rsn1 key
        case $key in
            $'\x1b') # ESC sequence
                read -rsn2 -t 0.1 key
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

main() {
    sudo pacman -S --noconfirm --needed base-devel git
    if ! [ -x "$(command -v git)" ]; then
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..
    rm -rf yay
    fi
    yay -S --sudoloop --noconfirm --needed librewolf-bin

    sudo pacman -Sy --noconfirm
    sudo pacman -S --noconfirm --needed base-devel git bash-completion bat btop pavucontrol mpv feh nfs-utils nano usbutils gnome-keyring fuse ffmpeg steam ttf-jetbrains-mono-nerd noto-fonts-emoji gamescope unrar
}

setupEnvironment(){
    clear
       echo -ne "
    -----------------------------------------------------------------------
                     Välj ett Destop Environment    
    -----------------------------------------------------------------------
    "

    options=("Plasma" "DWM (Kommer snart!)")
    select_option "${options[@]}"

    case $? in
        0)
        sudo pacman -S --needed --noconfirm kdeconnect plasma sddm konsole kate dolphin ark flatpak
        sudo systemctl enable sddm.service
        wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/refs/heads/main/config/.bashrc -O $HOME/.bashrc
        ;;
        1) 
        echo "Kommer snart. Försök igen."; setupEnvironment;;
        *) echo "Fel alternativ. Försök igen."; setupEnvironment;;
    esac
}

OpenRazer() {
if lsusb | grep -q "Razer"; then
    sudo gpasswd -a $USER plugdev
    sudo pacman -S --noconfirm --needed linux-headers
    sudo pacman -S --noconfirm --needed openrazer-daemon
    yay -S --sudoloop --noconfirm --needed razergenie
    sudo systemctl enable openrazer-daemon
    sudo systemctl start openrazer-daemon
fi
}

GoXLRMini(){
if lsusb | grep -q "GoXLRMini"; then
    yay -S --sudoloop --noconfirm --needed goxlr-utility

    mkdir -p $HOME/.config/autostart

    wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/main/scripts/GoXLR_loopback.sh -O $HOME/.config/autostart/GoXLR_loopback.sh
    wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/main/config/autostart/GoXLR_loopback.desktop -O $HOME/.config/autostart/GoXLR_loopback.desktop
    wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/main/config/autostart/GoXLR_daemon.desktop -O $HOME/.config/autostart/GoXLR_daemon.desktop

    chmod +x $HOME/.config/autostart/GoXLR_loopback.sh
    chmod 600 $HOME/.config/autostart/GoXLR_loopback.desktop
    chmod 600 $HOME/.config/autostart/GoXLR_daemon.desktop

    sed -i "s|^Exec=.*|Exec=$HOME/.config/autostart/GoXLR_loopback.sh|" \
    "$HOME/.config/autostart/GoXLR_loopback.desktop"
fi
}

setupGrub () {
    clear
    echo -ne "  
    -----------------------------------------------------------------------
                        Välj ett grub tema                    
    -----------------------------------------------------------------------
    1) Cartoon Girl
    2) Aesthetic
    3) inget tema
    -----------------------------------------------------------------------
    "
    options=("Cartoon Girl" "Aesthetic" "inget tema")
    select_option "${options[@]}"
    case $? in
        0)
            sudo mkdir -p "/boot/grub/themes/CartoonGirl"
            sudo wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/refs/heads/main/config/Grub/CartoonGirl/theme.txt -O /boot/grub/themes/CartoonGirl/theme.txt
            sudo wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/refs/heads/main/config/Grub/CartoonGirl/select_w.png -O /boot/grub/themes/CartoonGirl/select_w.png
            sudo wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/refs/heads/main/config/Grub/CartoonGirl/select_e.png -O /boot/grub/themes/CartoonGirl/select_e.png
            sudo wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/refs/heads/main/config/Grub/CartoonGirl/select_c.png -O /boot/grub/themes/CartoonGirl/select_c.png
            sudo wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/refs/heads/main/config/Grub/CartoonGirl/norwester_22.pf2 -O /boot/grub/themes/CartoonGirl/norwester_22.pf2
            sudo wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/refs/heads/main/config/Grub/CartoonGirl/hackb_18.pf2 -O /boot/grub/themes/CartoonGirl/hackb_18.pf2
            sudo wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/refs/heads/main/config/Grub/CartoonGirl/Cartoon_Girl.png -O /boot/grub/themes/CartoonGirl/Cartoon_Girl.png
            sudo sed -i 's|^#\?GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/CartoonGirl/theme.txt"|' /etc/default/grub
        ;;
        1)
            sudo mkdir -p "/boot/grub/themes/Aesthetic"
            sudo wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/refs/heads/main/config/Grub/Aesthetic/theme.txt -O /boot/grub/themes/Aesthetic/theme.txt
            sudo wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/refs/heads/main/config/Grub/Aesthetic/select_w.png -O /boot/grub/themes/Aesthetic/select_w.png
            sudo wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/refs/heads/main/config/Grub/Aesthetic/select_e.png -O /boot/grub/themes/Aesthetic/select_e.png
            sudo wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/refs/heads/main/config/Grub/Aesthetic/select_c.png -O /boot/grub/themes/Aesthetic/select_c.png
            sudo wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/refs/heads/main/config/Grub/Aesthetic/hackb_18.pf2 -O /boot/grub/themes/Aesthetic/hackb_18.pf2
            sudo wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/refs/heads/main/config/Grub/Aesthetic/Aesthetic.png -O /boot/grub/themes/Aesthetic/Aesthetic.png
            sudo sed -i 's|^#\?GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/Aesthetic/theme.txt"|' /etc/default/grub
        ;;
        2) 
        echo "Inget tema valt";
        ;;
        *) echo "Fel alternativ. Försök igen."; setupGrub;;
    esac
    sudo grub-mkconfig -o /boot/grub/grub.cfg
}

setupFastfetch(){
    sudo pacman -S --needed --noconfirm fastfetch
    mkdir -p $HOME/.config/fastfetch
    clear
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
            wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/main/config/fastfetch/transgender/config.jsonc -O $HOME/.config/fastfetch/config.jsonc
            wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/main/config/fastfetch/transgender/trans.txt -O $HOME/.config/fastfetch/trans.txt
        ;;
        1)
            wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/main/config/fastfetch/nonbinary/config.jsonc -O $HOME/.config/fastfetch/config.jsonc
            wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/main/config/fastfetch/nonbinary/nonbinary.txt -O $HOME/.config/fastfetch/nonbinary.txt
        ;;
        2) 
        echo "Inget tema valt";
        ;;
        *) echo "Fel alternativ. Försök igen."; setupFastfetch;;
    esac
}

setupStarship(){
    sudo pacman -S --needed --noconfirm starship
    mkdir -p $HOME/.config
    clear
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
            wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/main/config/starship/transgender/starship.toml -O $HOME/.config/starship.toml
        ;;
        1)
            wget https://raw.githubusercontent.com/DeluxerPanda/Arch-scripts/main/config/starship/nonbinary/starship.toml -O $HOME/.config/starship.toml
        ;;
        2) 
        echo "Inget tema valt";
        ;;
        *) echo "Fel alternativ. Försök igen."; setupStarship;;
    esac
}

dualGPU(){
# Dual GPU setup (AMD + NVIDIA)
if lspci | grep -i 'vga' | grep -qi 'Radeon' && lspci | grep -i 'vga' | grep -qi 'nvidia'; then
    echo "Dual GPU setup detected (AMD + NVIDIA). Setting up quickpassthrough..."
    sudo pacman -S --needed --noconfirm go
    git clone https://github.com/HikariKnight/quickpassthrough.git
    cd quickpassthrough
    go mod download
    CGO_ENABLED=0 go build -ldflags="-X github.com/HikariKnight/quickpassthrough/internal/version.Version=$(git rev-parse --short HEAD)" -o quickpassthrough cmd/main.go
    chmod +x ./quickpassthrough
    ./quickpassthrough
    cd "$work_dir"
    rm -rf quickpassthrough
fi
}

    main
    clear
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    setupEnvironment
fi
    clear
    OpenRazer
    clear
    GoXLRMini
    clear
    setupGrub
    clear
    setupFastfetch
    clear
    setupStarship
    clear
    dualGPU
    clear
    echo "Du kan nu starta om datorn :D"
