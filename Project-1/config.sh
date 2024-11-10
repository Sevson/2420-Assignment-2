#!/bin/bash

# Config Script
# ---------------------
# This script sets symbolic links for configuration and executable files from a Git repository to specific directories on the user's system

# The script allows the user to:
#   - Specify a custom location to clone the repository.
#   - Organize cloned files into the ~/bin and ~/.config directories

# GitHub repository URL to clone
repo_to_clone="https://gitlab.com/cit2420/2420-as2-starting-files"

# Default directory to clone the repository; falls back to "$HOME/config_files" if no location is specified.
def_repo_loc="$HOME/config_files"

# `error_exit` function to handle error messages consistently throughout the script.
# If an error occurs function throws an error message and exits with a non-zero status code.
# Using functions for handling errorsfor reusability and readability.
# https://linuxize.com/post/bash-functions/
error_exit() {
    echo "Error: $1"
    exit 1
}

# Set the user directory based on the first command-line argumen default to $HOME.
user_dir="${1:-$HOME}"

# Check if Git is installed by verifying if the `git` command is available.
# Using `command -v` with `&>/dev/null` suppresses command output, checking if Git exists.
# If Git is not installed, the script calls `error_exit` to display an error and terminate.
if ! command -v git &>/dev/null; then
    error_exit "You need to install git to run this script"
fi

# Attempt to clone the repository to the default location. Throw error if repository cant be cloned
echo "Cloning repository to $def_repo_loc"
git clone "$repo_to_clone" "$def_repo_loc" || error_exit "Failed to clone repository"

# Check if the ~/bin directory exists in the user directory. If not, create it.
if [[ ! -d "$user_dir/bin" ]]; then
    echo "Creating bin directory at $user_dir/bin"
    mkdir -p "$user_dir/bin" || error_exit "Failed to create bin directory"
fi

# Generate a list of top-level directories in the cloned repository by using the `find` command.
# parameters used:
#   - `-maxdepth 1` limits the search to top-level directories.
#   - `-mindepth 1` excludes the root directory itself.
#   - `-type d` restricts results to directories only.
directories=$(find "$def_repo_loc" -maxdepth 1 -mindepth 1 -type d -not -path "*/.*")

# Iterate through each directory in `directories`. create a symbolic links based on its name.
for dir in ${directories[@]}; do
    
    # Extract the directory name from the full path, echo for readability / terminal flow
    dirname="${dir##*/}"
    echo -e "\nProcessing directory: $dirname"

    # Use a case statement to handle directories differently based on their name.
    # This makes the script adaptable to different types of files by targeting specific names.
    # https://linuxize.com/post/bash-case-statement/
    case "$dirname" in

        # If the directory is `bin`, create symbolic links for scripts in the ~/bin directory.
        bin)
            echo "Creating symbolic links for scripts in $dirname directory"
            # Find files in the bin directory and create symbolic links in ~/bin.
            for script in $(find "$dir" -maxdepth 1 -mindepth 1 -type f); do
                base="${script##*/}"  # Extract the script's base name
                ln -s "$script" "$user_dir/bin/$base" && echo "Created symbolic link for $base"
            done
            ;;

        # If the directory is `config`, create symbolic links in ~/.config for each subdirectory.
        config)
            echo "Creating symbolic links for config directories in $dirname"
            # Find subdirectories within config and link them to the user's ~/.config directory.
            for config_dir in $(find "$dir" -maxdepth 1 -mindepth 1 -type d); do
                base="${config_dir##*/}"  # Extract the directory's base name
                ln -s "$config_dir" "$user_dir/.config/$base" && echo "Created symbolic link for $base"
            done
            ;;

        # If the directory is `home`, create symbolic links for each file in the user's home directory.
        home)
            echo "Creating symbolic links for files in $dirname"
            # Find files in the home directory and create symbolic links in the user's home directory.
            for file in $(find "$dir" -maxdepth 1 -mindepth 1 -type f); do
                base="${file##*/}"  # Extract the file's base name
                ln -s "$file" "$user_dir/.$base" && echo "Created symbolic link for $base"
            done
            ;;

        # unkown directory error handling, script doesnt handle excecptions but will echo to line for readability (sorry idk the right word)
        *)
            echo "*** New directory ($dirname) found. Please edit the script to accommodate this directory. ***"
            ;;
    esac
done

# Check for an existing .bashrc file in the user's home directory.
# If found, remove it to avoid conflicts before creating a new symbolic link.
if [[ -f "$user_dir/.bashrc" ]]; then
    echo "Removing existing .bashrc in $user_dir"
    rm "$user_dir/.bashrc" || error_exit "Failed to remove existing .bashrc"
fi

# Create a symbolic link for the .bashrc file from the cloned repository.
# This links the repository's version of .bashrc to the user's home directory.
echo "Creating symbolic link for .bashrc"
ln -s "$def_repo_loc/home/bashrc" "$user_dir/.bashrc" && echo "Created symbolic link for .bashrc"

# Final message to confirm that symbolic links were created successfully.
echo "Symbolic links created successfully."
