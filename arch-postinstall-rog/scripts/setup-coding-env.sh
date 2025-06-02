#!/bin/bash

# Arch Linux Coding Environment Setup Script

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
        sudo pacman -S --noconfirm "$pkg_name" || error "Failed to install $pkg_name. Please check your internet connection and try again."
    else
        log "${GREEN}$pkg_name${NC} is already installed."
    fi
}

# Function to build and install an AUR package manually
install_aur_manual() {
    local pkg_name="$1"
    local aur_dir="/tmp/${pkg_name}-aur"

    log "Building and installing ${GREEN}$pkg_name${NC} from AUR..."

    if pacman -Q "$pkg_name" &>/dev/null; then
        log "${GREEN}$pkg_name${NC} is already installed."
        return
    fi

    mkdir -p "$aur_dir"
    git clone "https://aur.archlinux.org/${pkg_name}.git" "$aur_dir" || { error "Failed to clone AUR repository for $pkg_name."; return 1; }
    (cd "$aur_dir" && makepkg -si --noconfirm) || { error "Failed to build and install $pkg_name."; return 1; }
    rm -rf "$aur_dir"
    success "$pkg_name installed successfully."
}

# --- Installation and Configuration Functions ---

setup_nodejs_environment() {
    step "Setting up Node.js Environment"
    install_pacman "nodejs"
    install_pacman "npm"

    local node_version_manager
    while true; do
        read -rp "$(echo -e "${YELLOW}Do you want to use 'n' or 'nvm' for Node.js version management? (n/nvm): ${NC}")" node_version_manager
        case "$node_version_manager" in
            [Nn])
                log "Installing '${GREEN}n${NC}' (Node.js version manager)..."
                sudo npm install -g n || error "Failed to install 'n'."
                break
                ;;
            [Nn][Vv][Mm])
                log "Installing '${GREEN}nvm${NC}' (Node Version Manager)..."
                curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash || error "Failed to install 'nvm'."
                # Source NVM in current shell for immediate use
                export NVM_DIR="$HOME/.nvm"
                [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
                [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
                log "nvm installed. You may need to restart your terminal or source ~/.bashrc (or equivalent) for it to take full effect."
                break
                ;;
            *)
                error "Invalid choice. Please enter 'n' or 'nvm'."
                ;;
        esac
    done

    log "Installing ${GREEN}pnpm${NC}..."
    npm install -g pnpm || error "Failed to install pnpm."

    log "Installing ${GREEN}bun${NC}..."
    npm install -g bun || error "Failed to install bun."
    success "Node.js environment setup complete."
}

setup_go() {
    step "Installing Go (Optional)"
    if confirm "Do you want to install Go?"; then
        log "Installing ${GREEN}Go${NC}..."
        install_pacman "go"
        success "Go installed."
    else
        log "Skipping Go installation."
    fi
}

setup_vscode() {
    step "Installing Visual Studio Code"
    install_aur_manual "visual-studio-code-bin"
    success "Visual Studio Code installed."
}

setup_git() {
    step "Setting up Git"
    install_pacman "git"

    local current_user=$(whoami)
    log "Setting global Git username to ${GREEN}$current_user${NC}..."
    git config --global user.name "$current_user" || error "Failed to set Git username."

    local git_email
    read -rp "$(echo -e "${YELLOW}Enter your global Git email address: ${NC}")" git_email
    if [[ -n "$git_email" ]]; then
        git config --global user.email "$git_email" || error "Failed to set Git email."
        log "Git email set to ${GREEN}$git_email${NC}."
    else
        log "No Git email provided. Skipping Git email configuration."
    fi
    success "Git setup complete."
}

setup_ssh() {
    step "Configuring SSH"
    install_pacman "openssh"
    sudo systemctl enable sshd || error "Failed to enable sshd service."
    sudo systemctl start sshd || error "Failed to start sshd service."

    local existing_ssh_dir
    read -rp "$(echo -e "${YELLOW}Do you have an existing ~/.ssh directory to copy? Provide path or leave empty to skip: ${NC}")" existing_ssh_dir
    if [[ -n "$existing_ssh_dir" ]]; then
        if [[ -d "$existing_ssh_dir" ]]; then
            log "Copying contents of ${GREEN}$existing_ssh_dir${NC} to ~/.ssh..."
            mkdir -p "$HOME/.ssh"
            cp -r "$existing_ssh_dir"/* "$HOME/.ssh/" || error "Failed to copy SSH directory."
            chmod 700 "$HOME/.ssh"
            chmod 600 "$HOME/.ssh"/*
            success "SSH directory copied."
        else
            error "Provided SSH directory does not exist. Skipping copy."
        fi
    else
        if confirm "Do you want to generate new SSH keys?"; then
            local ssh_key_email
            read -rp "$(echo -e "${YELLOW}Enter your email address for the SSH key comment (leave empty for no comment): ${NC}")" ssh_key_email
            if [[ -n "$ssh_key_email" ]]; then
                ssh-keygen -t rsa -b 4096 -C "$ssh_key_email" || error "Failed to generate SSH keys."
            else
                ssh-keygen -t rsa -b 4096 || error "Failed to generate SSH keys."
            fi
            log "SSH keys generated. Remember to add your public key to services like GitHub."
            success "SSH keys generated."
        else
            log "Skipping SSH key generation."
        fi
    fi
    success "SSH configuration complete."
}

setup_docker() {
    step "Setting up Docker"
    install_pacman "docker"
    install_pacman "docker-compose"

    log "Applying Docker post-installation steps (manage Docker as a non-root user)..."
    sudo usermod -aG docker "$USER" || error "Failed to add user to docker group. You may need to log out and back in for changes to take effect."

    log "Enabling and starting Docker daemon..."
    sudo systemctl enable docker || error "Failed to enable docker service."
    sudo systemctl start docker || error "Failed to start docker service."
    success "Docker setup complete. You may need to log out and back in for group changes to take effect."
}

setup_zsh_oh_my_posh() {
    step "Setting up Zsh and Oh My Posh"

    local is_gnome=false
    if confirm "Are you using the GNOME desktop environment?"; then
        is_gnome=true
        log "GNOME detected. Installing ${GREEN}gnome-terminal-transparency${NC} from AUR..."
        install_aur_manual "gnome-terminal-transparency"
    fi

    install_pacman "zsh"
    install_pacman "zsh-completions"

    log "Changing default user shell to ${GREEN}/usr/bin/zsh${NC}..."
    chsh -s /usr/bin/zsh "$USER" || error "Failed to change default shell. You may need to do this manually."

    log "Ensuring ${GREEN}~/.oh-my-posh${NC} directory exists..."
    mkdir -p "$HOME/.oh-my-posh"

    log "Installing Oh My Posh..."
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.oh-my-posh" || error "Failed to install Oh My Posh."

    log "Downloading Meslo font..."
    "$HOME"/.oh-my-posh font install meslo || error "Failed to download Meslo font. Make sure Oh My Posh is correctly installed."

    if $is_gnome; then
        log "Setting 'MesloLGM Nerd Font' as the default monospace font for GNOME terminal..."
        # Attempt to get the default profile ID dynamically
        local profile_id=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
        if [[ -n "$profile_id" ]]; then
            gsettings set org.gnome.Terminal.Profile:/org/gnome/terminal/legacy/profiles:/"$profile_id"/ font 'MesloLGM Nerd Font 10' || error "Failed to set GNOME Terminal font."
            success "GNOME Terminal font set."
        else
            error "Could not determine default GNOME Terminal profile ID. You may need to manually set the font."
        fi
    fi

    log "Adding Oh My Posh initialization to ${GREEN}~/.zshrc${NC}..."
    # Check if the lines already exist to prevent duplicates
    grep -q 'eval "$(oh-my-posh init zsh)"' "$HOME/.zshrc" || echo 'eval "$(oh-my-posh init zsh)"' >> "$HOME/.zshrc"
    grep -q 'export PATH=$PATH:~/.oh-my-posh' "$HOME/.zshrc" || echo 'export PATH=$PATH:~/.oh-my-posh' >> "$HOME/.zshrc"
    success "Zsh and Oh My Posh setup complete. Please restart your terminal or source ~/.zshrc for changes to take effect."
}

# --- CLI Menu ---

display_menu() {
    clear
    echo -e "${GREEN}==========================================${NC}"
    echo -e "${GREEN}  Arch Linux Coding Environment Setup     ${NC}"
    echo -e "${GREEN}==========================================${NC}"
    echo -e "Choose the components to install/configure:"
    echo "  1) Node.js Environment (Node, npm, n/nvm, pnpm, bun)"
    echo "  2) Go (Optional)"
    echo "  3) Visual Studio Code (AUR)"
    echo "  4) Git Setup"
    echo "  5) SSH Configuration"
    echo "  6) Docker Setup"
    echo "  7) Zsh and Oh My Posh Customization"
    echo -e "${YELLOW}  A) Install All Components${NC}"
    echo -e "${RED}  Q) Quit${NC}"
    echo -e "${GREEN}------------------------------------------${NC}"
}

handle_menu_choice() {
    case "$1" in
        1) setup_nodejs_environment ;;
        2) setup_go ;;
        3) setup_vscode ;;
        4) setup_git ;;
        5) setup_ssh ;;
        6) setup_docker ;;
        7) setup_zsh_oh_my_posh ;;
        [Aa])
            log "Initiating full installation..."
            TOTAL_TASKS=7 # Set total tasks for "Install All"
            CURRENT_TASK=0 # Reset for full install
            setup_nodejs_environment
            setup_go
            setup_vscode
            setup_git
            setup_ssh
            setup_docker
            setup_zsh_oh_my_posh
            ;;
        [Qq])
            log "Exiting setup script. Goodbye!"
            exit 0
            ;;
        *) error "Invalid choice. Please enter a valid option." ;;
    esac
    echo -e "\nPress any key to return to the menu..."
    read -n 1 -s
}

# --- Main Function ---

main() {
    log "Starting Arch Linux Coding Environment Setup..."

    # Check for root privileges
    if [[ "$EUID" -eq 0 ]]; then
        error "This script should not be run as root. Please run it as a regular user."
        exit 1
    fi

    # Update system as a first step, always
    step "Updating System Packages"
    sudo pacman -Syu --noconfirm || error "Failed to update system."
    success "System updated."

    # Determine total tasks for the stepper based on initial menu or full install
    # This is a bit tricky with a menu, so we'll set it dynamically when a choice is made.

    while true; do
        display_menu
        read -rp "$(echo -e "${BLUE}Enter your choice: ${NC}")" choice
        handle_menu_choice "$choice"
    done

    log "Arch Linux Coding Environment Setup Complete!"
    log "Please log out and log back in, or restart your system, for all changes (especially Docker group membership) to take full effect."
    log "Remember to manually set the GNOME Terminal font if the automatic setting failed."
}

# Execute the main function
main "$@"