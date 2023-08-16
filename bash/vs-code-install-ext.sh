#!/bin/bash

# Default source file
default_file="vscode_extensions.txt"

function install_extensions_from_file() {
    local source_file="$1"

    if [[ ! -f "$source_file" ]]; then
        echo "Error: File '$source_file' not found!"
        exit 1
    fi

    # Read each extension from the file and install
    while IFS= read -r extension; do
        if [[ ! -z "$extension" && ! "$extension" =~ ^\s*# && ! "$extension" =~ ^\s*Installed ]]; then
            code --install-extension "$extension"
        fi
    done < "$source_file"
}

function install_extensions_from_url() {
    local url="$1"

    curl -s "$url" | while IFS= read -r extension; do
        if [[ ! -z "$extension" && ! "$extension" =~ ^\s*# && ! "$extension" =~ ^\s*Installed ]]; then
            code --install-extension "$extension"
        fi
    done
}

function display_help() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  --source <file_path>        Specify the source file containing extensions. Default is 'vscode_extensions.txt'."
    echo "  --source-online <url>       Specify the online source URL containing extensions."
    echo "  --help                      Display this help message."
    echo
    echo "This script installs VS Code extensions listed in a file or an online source. By default, it reads from 'vscode_extensions.txt'."
}

# Main script logic
if [[ "$1" == "--help" ]]; then
    display_help
    exit 0
elif [[ "$1" == "--source" && -n "$2" ]]; then
    install_extensions_from_file "$2"
elif [[ "$1" == "--source-online" && -n "$2" ]]; then
    install_extensions_from_url "$2"
else
    install_extensions_from_file "$default_file"
fi

