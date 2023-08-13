![Arch Linux Logo](https://archlinux.org/static/logos/archlinux-logo-dark-90dpi.ebdee92a15b3.png) 

# Arch Linux Post-Installation
After an entire installation, we only get a `tty` (Simple black terminal). We need GUI, divers and essential softwares to get going.

## Drivers
* Audio: `pulseaudio` or `pipewire`
* Integrated GPU: `xf86-video-intel` or `xf86-video-amd`
* Dedicated/Hybrid GPU: Refer to [Nvidia Driver Installation for Arch Linux](https://github.com/khaledCSE/selfMade-Tutorials/blob/main/arch-linux-nvidia-driver.md)

## GUI: Display Server, Desktop Environment and Built-in Apps
* Display Server: Mostly `xorg`
* For choosing the DE, refer to: [ArchWiki Desktop Environments](https://wiki.archlinux.org/title/Desktop_environment)
  * For older laptops or simply more performant DE, choose `XFCE`
  * For the highest customization and complete DE, choose `KDE`
  * Windows-like DE: `Cinnamon`
  * Mac users: `Gnome` or `Deepin`
* Every DE has their own set of built-in apps. For example gnome has gnome-extra

