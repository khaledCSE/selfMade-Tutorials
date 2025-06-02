Write me a script that would automate the *Desktop Customization* for my **Asus ROG Zephyrus G14 GA403UV** in *Arch Linux*. The script should be self-contained and prioritize best practices, modularity, and readability. Please use functions extensively, with a main function to orchestrate the entire process.

I Use **Gnome and GDM** normally.

## Prerequisits
* Install `gnome-browser-connector` and enable the gnome extentions called `User Themes`, `Blur My Shell`, `Dash2Doc Animated` (all three for shell customizations) and `Clipboard Indicator`
* Use `~/Downloads/theming` for further customizations as `cwd`

## GTK Theme
I'll use the WhiteSur GTK theme from: https://github.com/vinceliuice/WhiteSur-gtk-theme.git
* Clone the repo with `git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1` and `cd` into it.
* Give mod permission to both `install.sh` and `tweaks.sh`
* Install the theme with the following flags:
    ```
    -N, --nautilus [stable|normal|mojave|glassy|right]: choose glassy
   Set Nautilus style. Default is BigSur-like style (stabled sidebar)

   -HD, --highdefinition 
   Set to High Definition size. Default is laptop size

   -l, --libadwaita 
   Install theme into gtk4.0 config for libadwaita. Default is dark version

   --shell, --gnomeshell 
   Tweaks for gnome-shell. Options:

     1. -i, -icon [apple|simple|gnome|ubuntu|tux|arch|manjaro|fedora|debian|void|opensuse|popos|mxlinux|zorin|budgie|gentoo]
     Set gnome-shell panel 'Activities' icon. Default is 'standard'
     Choose arch here
    
    Tweaks for GDM theme. options

  -g, --gdm    Without options default GDM theme will install... 

      1. -i, -icon [apple|simple|gnome|ubuntu|tux|arch|manjaro|fedora|debian|void|opensuse|popos|mxlinux|zorin|budgie|gentoo]   Set GDM panel 'Activities' icon Default is 'standard' (choose arch)

      2. -b, -background [default|blank|IMAGE_PATH]   Set GDM background image Default is BigSur-like wallpaper (choose ./images/wallpaper.jpg; i'll place an hd wallpaper there)
    ```
* Apply the themes in shell and legacy applications

## Icon Theme
I'll use the WhiteSur GTK theme from: https://github.com/vinceliuice/WhiteSur-icon-theme

* Do the same clone, permission and install it with `install.sh`
* Apply this as the icon theme

## Misc
Insall `lsd`, `fastfetch`, `inxi`, `htop` and some easter eggs (take the liberty here)