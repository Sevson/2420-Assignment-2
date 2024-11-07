#!/bin/bash

# Symbolic Link Script
# This script creates symbolic links from the repository files to the directory location
# Also allows the user to specify where to clone the repository and config files

# GitHub repository location
repo_to_clone="https://gitlab.com/cit2420/2420-as2-starting-files"
def_repo_loc="$HOME/config_files"

# Function for error handling (for function practice)
# https://linuxize.com/post/bash-functions/
error_exit() {
    echo "Error: $1"
    exit 1
}

# Set User Directory (default to $HOME if not specified)
user_dir="${1:-$HOME}"

# Checking if Git is installed on system + /dev/null to discard output
if ! command -v git &>/dev/null; then
    error_exit "You need to install git to run this script"
fi

# Check if the user specified a custom location to clone the repository, if not use the default
echo "Cloning repository to $def_repo_loc"
git clone "$repo_to_clone" "$def_repo_loc" || error_exit "Failed to clone repository"

# Create bin directory if it doesn't exist.
if [[ ! -d "$user_dir/bin" ]]; then
    echo "Creating bin directory at $user_dir/bin"
    mkdir -p "$user_dir/bin" || error_exit "Failed to create bin directory"
fi

# List of full paths to directories in the cloned repository
directories=$(find "$def_repo_loc" -maxdepth 1 -mindepth 1 -type d -not -path "*/.*")

# Iterate through the directories variable
for dir in ${directories[@]}; do
    
    # Easier to follow iteration process
    dirname="${dir##*/}"
    echo -e "\nProcessing directory: $dirname"

    # Case handling with below statements
    # https://linuxize.com/post/bash-case-statement/
    case "$dirname" in

        # if bin directory, creates symbolic links for scripts in ~/bin
        bin)
            echo "Creating symbolic links for scripts in $dirname directory"
            for script in $(find "$dir" -maxdepth 1 -mindepth 1 -type f); do
                base="${script##*/}"  # Extract the script's base name
                ln -s "$script" "$user_dir/bin/$base" && echo "Created symbolic link for $base"
            done
            ;;

        # if config directory, creates symbolic links for config directories in ~/.config
        config)
            echo "Creating symbolic links for config directories in $dirname"
            for config_dir in $(find "$dir" -maxdepth 1 -mindepth 1 -type d); do
                base="${config_dir##*/}"  # Extract the directory's base name
                ln -s "$config_dir" "$user_dir/.config/$base" && echo "Created symbolic link for $base"
            done
            ;;

        # if home directory, creates symbolic links for files in the user's home directory
        home)
            echo "Creating symbolic links for files in $dirname"
            for file in $(find "$dir" -maxdepth 1 -mindepth 1 -type f); do
                base="${file##*/}"  # Extract the file's base name
                ln -s "$file" "$user_dir/.$base" && echo "Created symbolic link for $base"
            done
            ;;

        # Handling unexpected directories
        *)
            echo "*** New directory ($dirname) found. Please edit the script to accommodate this directory. ***"
            ;;
    esac
done

# Check if a .bashrc file exists in the user's home directory and remove it if found
if [[ -f "$user_dir/.bashrc" ]]; then
    echo "Removing existing .bashrc in $user_dir"
    rm "$user_dir/.bashrc" || error_exit "Failed to remove existing .bashrc"
fi

# Create a symbolic link for the .bashrc file
echo "Creating symbolic link for .bashrc"
ln -s "$def_repo_loc/home/bashrc" "$user_dir/.bashrc" && echo "Created symbolic link for .bashrc"

echo "Symbolic links created successfully."
