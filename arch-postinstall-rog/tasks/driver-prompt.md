This would automate the driver installation for my **Asus ROG Zephyrus G14 GA403UV** in *Arch Linux*. The script should be self-contained and prioritize best practices, modularity, and readability. Please use functions extensively, with a main function to orchestrate the entire process.

This laptop uses hybrid graphics of *AMD Radeon 780M* as `iGPU` and *NVIDIA RTX 4060 (mobile)* as `dGPU`. You'll need to install the following:
## Prerequisits
Install `reflector` and run `sudo reflector --sort rate -c GB,BD --save /etc/pacman.d/mirrorlist --verbose` and run `sudo pacman -Syy` to get the fastest of mirrors.

## Asus G14 Specific Custom Kernel
* Add the following keys as `sudo`:
    ```bash
    sudo pacman-key --recv-keys 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
    sudo pacman-key --finger 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
    sudo pacman-key --lsign-key 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
    sudo pacman-key --finger 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
    ```
* Add the following to `/etc/pacman.conf`:
    ```bash
    [g14]
    Server = https://arch.asus-linux.org
    ```
* Update the system: `sudo pacman -Suy`
* Install the kernel: `sudo pacman -Sy linux-g14 linux-g14-headers`
*  Regenerate boot menu or add a new boot entry: `grub-mkconfig -o /boot/grub/grub.cfg`

## Processor Microcode (uCode)
Install *AMD Microcode* (with `amd-ucode`) for better optimization of the *AMD Ryzen 9 8945HS (16) @ 5.26 GHz*.

## Graphics Drivers
Both AMD and NVIDIA Drivers will be needed.
### Prerequisits 
* We'll enable the `multilib` repository for 32 bit driver support as it will be needed for many 32 bit games. 
* Also enable some easter eggs say `Colors` and `ILoveCandy` inside `/etc/pacman.conf`
* Sync the repositories with `sudo pacman -Syy`
### AMD Radeon 780M (iGPU)
Install Mesa and its's Utilities with their `lib32` versions like `xf86-video-amdgpu mesa mesa-utils mesa-demos vulkan-radeon`.
### NVIDIA RTX 4060 mobile (dGPU)
Install `nvidia-open-dkms nvidia-utils opencl-nvidia` as this is custom kernel (g14) and the GPU is above Turing (RTX 4060).

### Asusctl - custom fan profiles, anime, led control etc.
* Install using: `pacman -S asusctl power-profiles-daemon`
* Enable Service: `systemctl enable --now power-profiles-daemon.service`

### Supergfxctl - graphics switching
The same rules as for asusctl, 
* Install: `pacman -S supergfxctl switcheroo-control`
* Enable Service: 
    ```
    systemctl enable --now supergfxd
    systemctl enable --now switcheroo-control
    ```
### ROG Control Center
Install `pacman -S rog-control-center`

### Audio and Bluetooth
Install `pipewire`, `alsa` and `bluez`
