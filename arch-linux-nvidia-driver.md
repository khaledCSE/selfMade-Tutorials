<p float="left">
  <img src="https://archlinux.org/static/logos/archlinux-logo-dark-90dpi.ebdee92a15b3.png" width="49%" />
  <img src="images/nvidia-logo.png" width="49%" />
</p>

# Nvidia Driver Installation for Arch Linux
> No reboot during installation please

## Prerequisites
### Enable Multilib Repository
* Update the system with `sudo pacman -Syyu`
* Install required packages: `sudo pacman -S base-devel linux-headers git --needed`
* Install (if not already) *yay*
  * Clone yay repository: `git clone https://aur.archlinux.org/yay.git`
  * Go there: `cd yay`
  * Build and install: `makepkg -si`
* Enable multilib repository:
  * Open pacman config: `sudo nano /etc/pacman.conf`
  * Uncomment lines that have `[multilib]` and `Include = /etc/pacman.d/mirrorlist`
  * Save the file
  * Full system upgrade: `sudo pacman -Syu`

## Install the driver packages
* This step might be a bit confusing. First find your [nvidia card from this list here](https://nouveau.freedesktop.org/CodeNames.html)
* Check what driver packages you need to install from the list below

| Driver name  | Base driver | OpenGL | OpenGL (multilib) |
| ------------- | ------------- | ------------- |  ------------ | 
| Maxwell (NV110) series and newer  | nvidia | nvidia-utils | lib32-nvidia-utils |
| Kepler (NVE0) series  | nvidia-470xx-dkms  | nvidia-470xx-utils | lib32-nvidia-470xx-utils |
| GeForce 400/500/600 series cards [NVCx and NVDx] | nvidia-390xx  | nvidia-390xx-utils  | lib32-nvidia-390xx-utils |

* Install the correct packages, for example ```yay -S nvidia-470xx-dkms nvidia-470xx-utils lib32-nvidia-470xx-utils```
* I also recommend you to install nvidia-settings via ```yay -S nvidia-settings```

## Enable DRM kernel mode setting
1. Add the kernel parameter
- Go to your grub file with ```sudo nano /etc/default/grub```
- Find ```GRUB_CMDLINE_LINUX_DEFAULT```
- Append the line with ```nvidia-drm.modeset=1```
- For example: ```GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvidia-drm.modeset=1"```
- Save the file with *CTRL+O*
- Finish the grub config with ```sudo grub-mkconfig -o /boot/grub/grub.cfg```
2. Add the early loading
- Go to your mkinitcpio configuration file with ```sudo nano /etc/mkinitcpio.conf```
- Find ```MODULES=()```
- Edit the line to match ```MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)```
- Save the file with *CTRL+O*
- Finish the mkinitcpio configuration with ```sudo mkinitcpio -P```
3. Adding the pacman hook
- Find the *nvidia.hook* in this repository, make a local copy and open the file with your preferred editor
- Find ```Target=nvidia```
- Replace the *nvidia* with the base driver you installed, e.g. ```nvidia-470xx-dkms```
- Save the file and move it to ```/etc/pacman.d/hooks/``` , for example with ```sudo mv ./nvidia.hook /etc/pacman.d/hooks/```

## Reboot and enjoy!
You can now safely reboot and enjoy the proprietary nvidia drivers. If you have any problems check the Arch Linux Wiki or the forums for common pitfalls and questions.