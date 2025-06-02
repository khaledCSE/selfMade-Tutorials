# Boot Windows/ISO ISO with Arch Linux
## Prerequisits
* `sudo pacman -S wimtools`
* `yay -S woeusb`

Copy the iso to an accessible directory say **Downloads** and open terminal/cd into it.

* Unmount the flash drive
* Now run `sudo woeusb --partition <name>*.iso /dev/sd1`

>> Assuming `/dev/sda1` is the mount point for the flash drive.