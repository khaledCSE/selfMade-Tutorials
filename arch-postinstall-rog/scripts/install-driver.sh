#!/bin/bash

# Arch Linux Driver Installation Script for Asus ROG Zephyrus G14 GA403UV

# --- Global Variables ---
TOTAL_TASKS=0
CURRENT_TASK=0

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

# Function to prompt for user confirmation
confirm() {
    read -rp "$(echo -e "${YELLOW}$1 (y/n): ${NC}")" response
    [[ "$response" =~ ^[Yy]$ ]]
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

# --- Installation and Configuration Functions ---

setup_prerequisites() {
    step "Setting up Prerequisites (Reflector and Mirrorlist)"
    log "Installing ${GREEN}reflector${NC}..."
    install_pacman "reflector" || return 1

    log "Updating mirrorlist with reflector..."
    sudo reflector --sort rate -c GB,BD --save /etc/pacman.d/mirrorlist --verbose || { error "Failed to update mirrorlist."; return 1; }
    log "Syncing pacman databases..."
    sudo pacman -Syy || { error "Failed to sync pacman databases."; return 1; }
    success "Prerequisites setup complete."
}

setup_asus_g14_kernel() {
    step "Installing Asus G14 Specific Custom Kernel"
    log "Adding G14 kernel signing keys..."
    sudo pacman-key --recv-keys 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35 || { error "Failed to receive G14 kernel key."; return 1; }
    sudo pacman-key --finger 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35 || { error "Failed to finger G14 kernel key."; return 1; }
    sudo pacman-key --lsign-key 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35 || { error "Failed to sign G14 kernel key."; return 1; }
    sudo pacman-key --finger 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35 || { error "Failed to re-finger G14 kernel key."; return 1; }
    success "G14 kernel keys added."

    log "Adding [g14] repository to /etc/pacman.conf..."
    if ! grep -q "\[g14\]" /etc/pacman.conf; then
        echo -e "\n[g14]\nServer = https://arch.asus-linux.org" | sudo tee -a /etc/pacman.conf >/dev/null || { error "Failed to add [g14] repository."; return 1; }
        log "Added [g14] repository."
    else
        log "[g14] repository already exists in pacman.conf."
    fi

    log "Updating system with new repository..."
    sudo pacman -Suy || { error "Failed to update system with new repository."; return 1; }
    success "System updated with [g14] repository."

    log "Installing ${GREEN}linux-g14${NC} and ${GREEN}linux-g14-headers${NC}..."
    sudo pacman -Sy linux-g14 linux-g14-headers || { error "Failed to install G14 kernel."; return 1; }
    success "Asus G14 specific kernel installed."

    log "Regenerating GRUB boot menu..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg || { error "Failed to regenerate GRUB config. Ensure GRUB is installed correctly."; return 1; }
    success "GRUB boot menu regenerated."
}

install_processor_microcode() {
    step "Installing Processor Microcode (AMD uCode)"
    log "Installing ${GREEN}amd-ucode${NC}..."
    install_pacman "amd-ucode" || return 1
    log "Please ensure your bootloader (e.g., GRUB) is configured to load the microcode. This is usually handled automatically by GRUB if it's set up correctly."
    success "AMD Microcode installed."
}

setup_graphics_drivers() {
    step "Configuring Graphics Drivers"

    log "Enabling ${GREEN}multilib${NC} repository and adding pacman easter eggs..."
    sudo sed -i "/\[multilib\]/{n;s/^#//}" /etc/pacman.conf # Uncomment multilib
    sudo sed -i "/\[multilib\]/{N;s/Include/#Include/}" /etc/pacman.conf # Uncomment multilib Include
    if ! grep -q "Color" /etc/pacman.conf; then
        sudo sed -i '/#Color/s/^#//' /etc/pacman.conf # Uncomment Color
    fi
    if ! grep -q "ILoveCandy" /etc/pacman.conf; then
        sudo sed -i '/# Misc options/a ILoveCandy' /etc/pacman.conf # Add ILoveCandy
    fi
    log "Multilib repository enabled and pacman easter eggs added."

    log "Syncing repositories after pacman.conf changes..."
    sudo pacman -Syy || { error "Failed to sync repositories after pacman.conf changes."; return 1; }
    success "Pacman configuration updated and synced."

    log "Installing ${GREEN}AMD Radeon 780M (iGPU)${NC} drivers..."
    sudo pacman -S --noconfirm xf86-video-amdgpu mesa mesa-utils mesa-demos vulkan-radeon lib32-mesa lib32-vulkan-radeon || { error "Failed to install AMD drivers."; return 1; }
    success "AMD Radeon 780M drivers installed."

    log "Installing ${GREEN}NVIDIA RTX 4060 (dGPU)${NC} drivers..."
    sudo pacman -S --noconfirm nvidia-open-dkms nvidia-utils opencl-nvidia || { error "Failed to install NVIDIA drivers."; return 1; }
    success "NVIDIA RTX 4060 drivers installed."
    log "NVIDIA setup is for the custom G14 kernel and modern Turing+ GPU."
}

install_asus_utilities() {
    step "Installing Asus Utilities (Asusctl, Supergfxctl, ROG Control Center)"
    log "Installing ${GREEN}asusctl${NC} and ${GREEN}power-profiles-daemon${NC}..."
    install_pacman "asusctl" || return 1
    install_pacman "power-profiles-daemon" || return 1

    log "Enabling ${GREEN}power-profiles-daemon.service${NC}..."
    sudo systemctl enable --now power-profiles-daemon.service || { error "Failed to enable power-profiles-daemon."; return 1; }
    success "Asusctl and Power Profiles Daemon installed and enabled."

    log "Installing ${GREEN}supergfxctl${NC} and ${GREEN}switcheroo-control${NC}..."
    install_pacman "supergfxctl" || return 1
    install_pacman "switcheroo-control" || return 1

    log "Enabling ${GREEN}supergfxd${NC} and ${GREEN}switcheroo-control${NC} services..."
    sudo systemctl enable --now supergfxd || { error "Failed to enable supergfxd."; return 1; }
    sudo systemctl enable --now switcheroo-control || { error "Failed to enable switcheroo-control."; return 1; }
    success "Supergfxctl and Switcheroo Control installed and enabled."

    log "Installing ${GREEN}rog-control-center${NC}..."
    install_pacman "rog-control-center" || return 1
    success "ROG Control Center installed."
}

install_audio_bluetooth() {
    step "Installing Audio and Bluetooth Drivers"
    log "Installing ${GREEN}pipewire${NC}..."
    install_pacman "pipewire" || return 1
    log "Installing ${GREEN}alsa-utils${NC} (for ALSA utilities like alsamixer)..."
    install_pacman "alsa-utils" || return 1
    log "Installing ${GREEN}bluez${NC} (Bluetooth daemon) and ${GREEN}bluez-utils${NC} (Bluetooth utilities)..."
    install_pacman "bluez" || return 1
    install_pacman "bluez-utils" || return 1 # Provides bluetoothctl
    log "Enabling ${GREEN}bluetooth.service${NC}..."
    sudo systemctl enable --now bluetooth.service || { error "Failed to enable bluetooth service."; return 1; }
    success "Audio and Bluetooth drivers installed and services enabled."
}

# --- Main Function ---

main() {
    log "Starting Arch Linux Driver Installation for Asus ROG Zephyrus G14 GA403UV..."

    # Check for root privileges
    if [[ "$EUID" -eq 0 ]]; then
        error "This script should not be run as root. Please run it as a regular user (it will use sudo when needed)."
        exit 1
    fi

    # Set total tasks for the stepper
    TOTAL_TASKS=6 # Prerequisites, Kernel, Microcode, Graphics, Asus Utilities, Audio/Bluetooth

    # Execute installation steps
    setup_prerequisites && \
    setup_asus_g14_kernel && \
    install_processor_microcode && \
    setup_graphics_drivers && \
    install_asus_utilities && \
    install_audio_bluetooth

    if [[ $? -eq 0 ]]; then
        echo -e "\n${GREEN}==========================================${NC}"
        echo -e "${GREEN}  Driver Installation Complete!             ${NC}"
        echo -e "${GREEN}==========================================${NC}"
        log "IMPORTANT: A reboot is ${RED}HIGHLY RECOMMENDED${NC} for all driver changes and kernel updates to take full effect."
        log "After reboot, verify your drivers and utilities are working as expected."
        log "You can use 'supergfxctl -s' to check graphics status and switch modes."
    else
        echo -e "\n${RED}==========================================${NC}"
        echo -e "${RED}  Driver Installation Failed!               ${NC}"
        echo -e "${RED}==========================================${NC}"
        error "One or more steps failed. Please review the error messages above and try to resolve the issues."
    fi
}

# Execute the main function
main "$@"