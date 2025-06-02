I need a comprehensive Arch Linux setup script for a fresh coding environment. The script should be self-contained and prioritize best practices, modularity, and readability. Please use functions extensively, with a main function to orchestrate the entire process.

The script should perform the following installations and configurations:

### Node.js Environment:

#### Install Node.js and npm.
Prompt the user to choose between `n` or `nvm` for Node.js version management, then install the chosen tool.
Install pnpm and bun.

### Go (Optional):
Ask the user if they want to install Go. If yes, proceed with installation.

### Visual Studio Code:
Install `visual-studio-code-bin` from the AUR using `makepkg -si`. (This approach is preferred as `yay` or `paru` might not be installed, or the user might prefer a manual build).

### Git Setup:
* Install git.
* Automatically set the global Git username to the current system user `($(whoami))`.
* Prompt the user for their global Git email address and configure it.

### SSH Configuration:
* Install openssh and enable the sshd service.
* Ask the user if they have an existing ~/.ssh directory to copy. If provided, copy its contents to ~/.ssh.
* If no existing directory is provided, ask the user if they want to generate new SSH keys.
* If they agree to generate keys, prompt for their email address (for the key comment). If no email is provided, generate the keys without a comment.
* If they decline key generation, skip this step.

### Docker Setup:
* Install `docker` and `docker-compose`.
* Apply the necessary post-installation steps to manage Docker as a non-root user, as outlined in the official Docker documentation: https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user.
* Enable and start the Docker daemon.

### Zsh and Oh My Posh Customization:
* Ask the user if they are using the GNOME desktop environment.
* If yes, install `gnome-terminal-transparency` from the AUR.
* Install `zsh` and `zsh-completions`.
* Change the default user shell to `/usr/bin/zsh`.
* Ensure the `~/.oh-my-posh` directory exists.
* Install Oh My Posh using the recommended curl script: `curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.oh-my-posh`.
* Download the *Meslo* font using `oh-my-posh font install meslo`.
* If GNOME is detected, set *"MesloLGM Nerd Font"* as the default monospace font for the GNOME terminal.
* Add `eval "$(oh-my-posh init zsh)"` to `~/.zshrc` to initialize Oh My Posh.
* Add `export PATH=$PATH:~/.oh-my-posh` to `~/.zshrc` to ensure Oh My Posh executables are in the PATH.