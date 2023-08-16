#!/bin/bash

# File to which the extensions will be written
output_file="vscode_extensions.txt"

# Get list of extensions and store in an array
vscode_extensions=($(code --list-extensions))

# Write extensions to the file
# echo "Installed VS Code Extensions:" > $output_file
for extension in "${vscode_extensions[@]}"; do
    echo "$extension" >> $output_file
done

echo "Extensions have been written to $output_file"
