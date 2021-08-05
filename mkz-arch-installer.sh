#!/bin/bash

echo -e '\e[1;32m\e[1;32m'

# Function Prototypes
function mirror_region_check() {
    printf 'Are you from Bangladesh? (y/n): '
    read from_bd

    if [ $from_bd == 'y' ]
    then
        echo "test" >> ./test.txt
        sed -i '1iServer = http://mirror.xeonbd.com/archlinux/$repo/os/$arch\' /etc/pacman.d/mirrorlist
    fi
}

function browser_choice() {
    printf "\nBrowser Choices:\n1. Firefox\n2. Chromium\nEnter Choice: "
    read br_choice

    if [ $br_choice == 2 ]
    then
        sudo pacman -S chromium
    else
        sudo pacman -S Firefox
    fi
}

function just_formatted() {
    mirror_region_check

    printf '/n/nInstalling Base\n\n'
    ## Install linux base and firmware
    pacstrap /mnt base linux linux-firmware nano

    printf '/n/nGenerating Filesystem Info\n\n'
    ## Generate Filesystem Info
    genfstab -U /mnt >> /mnt/etc/fstab

    printf '/n/nPerforming chroot. Please run the script again and select stage 2\n\n'
    ## Change to root
    arch-chroot /mnt
}

function changed_root() {
    printf '/n/nSetting up Date-time and locale\n\n'
    ln -sf /usr/share/zoneinfo/Asia/Dhaka /etc/localtime
    hwclock --systohc
    locale-gen
    printf '/n/nConfiguring Host\n\n'
    echo "\nName of the host pc: "
    read hostname

    echo $hostname >> /etc/hostname
    host_content="127.0.0.1      localhost/n::1            localhost\n127.0.1.1      ${hostname}.localdomain   ${hostname}"
    echo $host_content >> /etc/hosts

    printf "\n\nSetting up root\n\n"
    passwd

    printf "echo username: "
    read username

    useradd -G wheel -m $username
    passwd $username

    printf "\n\nSetting up Network Manager\n\n"
    pacman -S networkmanager network-manager-applet

    printf "\n\nInstalling Build Essentials\n\n"
    pacman -S base-devel linux-headers openssh

    printf "\nUncomment %wheel ALL=ALL then save and exit\n"
    EDITOR=nano visudo

    printf "\n\nSetting up Bootloader (Grub)\n\n"
    pacman -Syu grub efibootmgr
    grub-install --target=x86_64-efi --efi-directory=/efi/ --bootloader-id=Arch
    grub-mkconfig -o /boot/grub/grub.cfg

    systemctl enable NetworkManager
    systemctl enable sshd

    printf "\n\nRemove installation medium after shutting down.\n\n"
    exit
    shutdown now
}

function post_install() {
    clear
    echo "Do you want a Desktop Environment(DE)? (y/n): "
    read want_de

    if [ $want_de == 'y' ]
    then
        printf "\nDE Choices:\n"
        printf "\n1. Cinnamon\n2. Deepin\n3. XFCE\n"
        printf "\nSelect DE: "
        read de_chose

        if [ $de_chose == 1 ]
        then
            sudo pacman -Syu xorg lightdm lightdm-gtk-greeter cinnamon nemo-fileroller xed zip unzip unrar gnome-terminal

            browser_choice
            sudo systemctl enable lightdm
            sudo reboot
        fi
    elif [ $de_chose == 2 ]
    then
        sudo pacman -Syu xorg lightdm deepin xterm zip unzip unrar xed
        browser_choice
        sudo systemctl enable lightdm
        sudo reboot
    elif [ $de_chose == 3 ]
    then
        sudo pacman -Syu xorg lightdm xfce4 xed zip unzip unrar lxterminal
        rowser_choice
        sudo systemctl enable lightdm
        sudo reboot
    else
        exit
    fi
}

printf "\e[36mIntallation Stages:\e[36m"
printf "\n1. Just formatted disk and mounted\n2. After chroot\n3. Post-install\n"
printf "\nWhat stage are you in: "
read install_stages

if [ $install_stages == 1 ]
then
    just_formatted
elif [ $install_stages == 2 ]
then
    changed_root
elif [ $install_stages == 3 ]
then
    post_install
else
    exit
fi
