#!/bin/bash

# Arch Linux Desktop Customization Script for Asus ROG Zephyrus G14 GA403UV

# --- Global Variables ---
TOTAL_TASKS=0
CURRENT_TASK=0
THEMING_DIR="$HOME/Downloads/theming"
WALLPAPER_PATH="$THEMING_DIR/WhiteSur-gtk-theme/images/wallpaper.jpg" # Assuming you place your wallpaper here

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Helper Functions ---

# Function to display messages with color
log() {
    echo -e "${BLUE}=> $1${NC}"
}

# Function to display error messages
error() {
    echo -e "${RED}ERROR: $1${NC}"
}

# Function to display success messages
success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

# Function to display a step in the process
step() {
    CURRENT_TASK=$((CURRENT_TASK + 1))
    echo -e "\n${YELLOW}TASK $CURRENT_TASK of $TOTAL_TASKS: $1${NC}"
}

# Function to install a package using pacman
install_pacman() {
    local pkg_name="$1"
    if ! pacman -Q "$pkg_name" &>/dev/null; then
        log "Installing ${GREEN}$pkg_name${NC}..."
        sudo pacman -S --noconfirm "$pkg_name" || { error "Failed to install $pkg_name."; return 1; }
    else
        log "${GREEN}$pkg_name${NC} is already installed."
    fi
    return 0
}

# Function to clone a git repository
clone_repo() {
    local repo_url="$1"
    local repo_dir="$2"
    if [[ -d "$repo_dir" ]]; then
        log "Repository ${GREEN}$(basename "$repo_dir")${NC} already cloned. Pulling latest changes..."
        (cd "$repo_dir" && git pull) || { error "Failed to pull latest changes for $(basename "$repo_dir")."; return 1; }
    else
        log "Cloning ${GREEN}$repo_url${NC} into ${GREEN}$repo_dir${NC}..."
        git clone "$repo_url" "$repo_dir" --depth=1 || { error "Failed to clone $repo_url."; return 1; }
    fi
    return 0
}

# --- Installation and Configuration Functions ---

setup_prerequisites() {
    step "Setting up Prerequisites (GNOME Extensions)"
    log "Installing ${GREEN}gnome-browser-connector${NC}..."
    install_pacman "gnome-browser-connector" || return 1

    log "Ensuring GNOME Shell Extensions are enabled via dconf..."
    # Enable User Themes extension
    gsettings set org.gnome.shell.extensions.user-theme enabled true 2>/dev/null || log "Could not enable User Themes. Ensure 'User Themes' extension is installed and available."
    # Enable Blur My Shell - Note: this requires the extension to be installed already
    gsettings set org.gnome.shell.extensions.blur-my-shell enabled true 2>/dev/null || log "Could not enable Blur My Shell. Ensure 'Blur My Shell' extension is installed."
    # Enable Dash to Dock Animated - Note: this requires the extension to be installed already
    gsettings set org.gnome.shell.extensions.dash-to-dock-animated enabled true 2>/dev/null || log "Could not enable Dash2Dock Animated. Ensure 'Dash2Doc Animated' extension is installed."
    # Enable Clipboard Indicator - Note: this requires the extension to be installed already
    gsettings set org.gnome.shell.extensions.clipboard-indicator enabled true 2>/dev/null || log "Could not enable Clipboard Indicator. Ensure 'Clipboard Indicator' extension is installed."

    log "Please ensure the above extensions are installed via browser or GNOME Extensions app if not already."
    success "Prerequisites setup complete."
}

install_whitesur_gtk_theme() {
    step "Installing WhiteSur GTK Theme"
    mkdir -p "$THEMING_DIR"
    clone_repo "https://github.com/vinceliuice/WhiteSur-gtk-theme.git" "$THEMING_DIR/WhiteSur-gtk-theme" || return 1

    local theme_path="$THEMING_DIR/WhiteSur-gtk-theme"
    if [[ ! -d "$theme_path" ]]; then
        error "WhiteSur GTK theme directory not found at $theme_path."
        return 1
    fi

    log "Changing directory to ${GREEN}$theme_path${NC}..."
    (
        cd "$theme_path" || { error "Failed to change directory to $theme_path."; return 1; }

        log "Giving execute permissions to install.sh and tweaks.sh..."
        chmod +x install.sh || { error "Failed to set execute permission for install.sh."; return 1; }
        chmod +x tweaks.sh || { error "Failed to set execute permission for tweaks.sh."; return 1; }

        log "Installing WhiteSur GTK Theme with specified flags..."
        # Nautilus style: glassy, High Definition, LibAdwaita support (dark), Shell tweaks with Arch icon
        ./install.sh -N glassy -HD -l --shell -i arch || { error "Failed to install WhiteSur GTK theme."; return 1; }
        success "WhiteSur GTK Theme installed."

        log "Applying GDM theme tweaks..."
        # Check if the wallpaper exists before attempting to set it
        if [[ -f "$WALLPAPER_PATH" ]]; then
            log "Setting GDM background to ${GREEN}$WALLPAPER_PATH${NC} and 'Activities' icon to Arch..."
            sudo ./tweaks.sh -g -i arch -b "$WALLPAPER_PATH" || { error "Failed to apply GDM theme tweaks. Ensure 'gdm-tools' is installed or manually set the GDM background."; }
            success "GDM theme tweaks applied. (Requires gdm-tools/manual config for background if issues)"
        else
            log "Custom wallpaper not found at ${RED}$WALLPAPER_PATH${NC}. Setting GDM icon only."
            sudo ./tweaks.sh -g -i arch || { error "Failed to apply GDM icon tweak."; }
            log "Please place your wallpaper at ${YELLOW}$WALLPAPER_PATH${NC} and re-run this section or set GDM background manually."
        fi
    ) || return 1 # Exit if any command in the subshell fails

    log "Applying WhiteSur theme for GTK and Shell via gsettings..."
    gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Dark" || error "Failed to set GTK theme."
    gsettings set org.gnome.shell.extensions.user-theme name "WhiteSur-Dark" || error "Failed to set Shell theme."
    success "WhiteSur GTK and Shell themes applied."
}

install_whitesur_icon_theme() {
    step "Installing WhiteSur Icon Theme"
    mkdir -p "$THEMING_DIR"
    clone_repo "https://github.com/vinceliuice/WhiteSur-icon-theme.git" "$THEMING_DIR/WhiteSur-icon-theme" || return 1

    local icon_theme_path="$THEMING_DIR/WhiteSur-icon-theme"
    if [[ ! -d "$icon_theme_path" ]]; then
        error "WhiteSur Icon theme directory not found at $icon_theme_path."
        return 1
    fi

    log "Changing directory to ${GREEN}$icon_theme_path${NC}..."
    (
        cd "$icon_theme_path" || { error "Failed to change directory to $icon_theme_path."; return 1; }

        log "Giving execute permissions to install.sh..."
        chmod +x install.sh || { error "Failed to set execute permission for install.sh."; return 1; }

        log "Installing WhiteSur Icon Theme..."
        ./install.sh || { error "Failed to install WhiteSur Icon theme."; return 1; }
    ) || return 1 # Exit if any command in the subshell fails

    log "Applying WhiteSur Icon Theme via gsettings..."
    gsettings set org.gnome.desktop.interface icon-theme "WhiteSur" || error "Failed to set Icon theme."
    success "WhiteSur Icon Theme installed and applied."
}

install_misc_utilities() {
    step "Installing Miscellaneous Utilities and Easter Eggs"
    log "Installing ${GREEN}lsd${NC} (LS Deluxe)..."
    install_pacman "lsd" || log "lsd might be in AUR if not found."

    log "Installing ${GREEN}fastfetch${NC}..."
    install_pacman "fastfetch" || return 1

    log "Installing ${GREEN}inxi${NC}..."
    install_pacman "inxi" || return 1

    log "Installing ${GREEN}htop${NC}..."
    install_pacman "htop" || return 1

    log "Adding some fun Easter Eggs to ~/.bashrc or ~/.zshrc (if they exist)..."
    local shell_rc=""
    if [[ -f "$HOME/.zshrc" ]]; then
        shell_rc="$HOME/.zshrc"
    elif [[ -f "$HOME/.bashrc" ]]; then
        shell_rc="$HOME/.bashrc"
    fi

    if [[ -n "$shell_rc" ]]; then
        if ! grep -q "neofetch" "$shell_rc"; then
            echo -e "\n# Daily dose of system info" >> "$shell_rc"
            echo "[[ -f /usr/bin/fastfetch ]] && fastfetch" >> "$shell_rc"
        fi
        if ! grep -q "cowthink" "$shell_rc"; then
            install_pacman "cowsay" || log "cowsay not installed, skipping cowthink."
            install_pacman "fortune-mod" || log "fortune-mod not installed, skipping fortune."
            if pacman -Q cowsay &>/dev/null && pacman -Q fortune-mod &>/dev/null; then
                echo -e "\n# Thought for the day" >> "$shell_rc"
                echo '[[ -f /usr/bin/fortune ]] && /usr/bin/fortune | /usr/bin/cowsay -f "$(ls /usr/share/cowsay/cows/ | shuf -n 1)"' >> "$shell_rc"
            fi
        fi
        success "Miscellaneous utilities and Easter Eggs added to $shell_rc."
        log "Remember to 'source $shell_rc' or restart your terminal to see changes."
    else
        error "No .bashrc or .zshrc found. Cannot add Easter Eggs."
    fi
}

# --- Main Function ---

main() {
    log "Starting Arch Linux Desktop Customization Script for Asus ROG Zephyrus G14 GA403UV..."

    # Check for root privileges (script will use sudo where necessary)
    if [[ "$EUID" -eq 0 ]]; then
        error "This script should not be run as root. Please run it as a regular user (it will use sudo when needed)."
        exit 1
    fi

    # Set total tasks for the stepper
    TOTAL_TASKS=4 # Prerequisites, GTK Theme, Icon Theme, Misc

    # Ensure the theming directory exists
    mkdir -p "$THEMING_DIR" || { error "Failed to create theming directory: $THEMING_DIR."; exit 1; }
    log "Theming directory set to: ${GREEN}$THEMING_DIR${NC}"

    # Execute customization steps
    setup_prerequisites && \
    install_whitesur_gtk_theme && \
    install_whitesur_icon_theme && \
    install_misc_utilities

    if [[ $? -eq 0 ]]; then
        echo -e "\n${GREEN}==========================================${NC}"
        echo -e "${GREEN}  Desktop Customization Complete!           ${NC}"
        echo -e "${GREEN}==========================================${NC}"
        log "IMPORTANT: To see all changes, you might need to:"
        log "1. ${YELLOW}Log out and log back in${NC} to refresh your GNOME session."
        log "2. If GDM theme changes aren't visible, a ${YELLOW}reboot${NC} might be required."
        log "3. For Easter Eggs in your shell, remember to run ${YELLOW}source ~/.zshrc${NC} (or ~/.bashrc) in open terminals."
        log "4. Manually place your desired HD wallpaper at ${YELLOW}$WALLPAPER_PATH${NC} if you haven't already, then re-run the GTK theme section to set the GDM background."
    else
        echo -e "\n${RED}==========================================${NC}"
        echo -e "${RED}  Desktop Customization Failed!             ${NC}"
        echo -e "${RED}==========================================${NC}"
        error "One or more steps failed. Please review the error messages above and try to resolve the issues."
    fi
}

# Execute the main function
main "$@"