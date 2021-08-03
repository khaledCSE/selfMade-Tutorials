#!/bin/bash

CYAN='\e[36m'
setfont ter-224b

## Install linux base and firmware
pacstrap /mnt base linux linux-firmware nano reflector

echo -e "${CYAN}/n/nGenerating Filesystem Info\n\n${CYAN}"

## Generate Filesystem Info
genfstab -U /mnt >> /mnt/etc/fstab

## Change to root
arch-chroot /mnt

echo -e "${CYAN}/n/nSelecting The Fastest Mirror (Bangladesh, India)\n\n${CYAN}"

## Select The Fastest Mirror
reflector --verbose --sort rate -c Bangladesh -c India --save /etc/pacman.d/mirrorlist

echo -e "${CYAN}/n/nSetting up Date-time and locale\n\n${CYAN}"

## Date-time and locale
ln -sf /usr/share/zoneinfo/Asia/Dhaka /etc/localtime

hwclock --systohc

locale-gen

echo -e "${CYAN}/n/nConfiguring host/n/n${CYAN}"

## Configuring host

echo "\nName of the host: "
read hostname

echo $hostname >> /etc/hostname

host_content="127.0.0.1      localhost/n::1            localhost\n127.0.1.1      ${hostname}.localdomain   ${hostname}"

## Setting up root
echo -e "${CYAN}\n\nSetting up root\n\n${CYAN}"

passwd

## Installing Network Manager
echo -e "${CYAN}\n\nSetting up Network Manager\n\n${CYAN}"

pacman -S networkmanager network-manager-applet 

## Installing Build Essentials
echo -e "${CYAN}\n\nInstalling Build Essentials\n\n${CYAN}"

pacman -S linux-headers base-devel

## Bootloader installation
echo -e "${CYAN}\n\nSetting up Bootloader (Grub)\n\n${CYAN}"

pacman -Syu grub efibootmgr

grub-install --target=x86_64-efi --efi-directory=/efi/ --bootloader-id=Arch

grub-mkconfig -o /boot/grub/grub.cfg

echo -e "${CYAN}\n\nDone! Eject the installer now\n\n${CYAN}"

exit
shutdown now