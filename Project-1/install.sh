#!/bin/bash

# Package Installation Script
# ---------------------------
# This script automates the installation of packages listed in a specified file (by default, "packages").
# It reads through each line in the file, ignores blank and commented lines, checks if each package is already installed,
# and installs any missing packages.

# Define the file containing the list of packages to install.
# This file should contain package names, one per line.
file="packages"

# Loop through each line in the specified package file.
# loop structure - reads each line from the input file and assigns it to the variable `package`.
# Reference for while loop and read file: https://www.javatpoint.com/bash-while-loop + https://www.javatpoint.com/bash-read-file
while read package; do

    # Skip empty lines or lines starting with `#`, which are comments.
    # `-z "$package"` checks if the line is empty (returns true for an empty string).
    # `"$package" == \#*` checks if the line starts with `#`, marking it as a comment.
    # If either condition is met, `continue` skips to the next line.
    # https://stackoverflow.com/questions/22080937/skip-blank-lines-when-iterating-through-file-line-by-line
    [[ -z "$package" || "$package" == \#* ]] && continue

    # Check if the package is already installed.
    # `pacman -Q "$package"` checks if a package is installed in Arch Linux systems.
    # Any output is redirected to /dev/null to suppress messages for a cleaner output.
    # Reference for pacman commands: https://devhints.io/pacman
    if pacman -Q "$package" &>/dev/null; then
        # If the package is found, output its name and version.
        echo "$(pacman -Q "$package") is already installed."

    # If the package is not found, proceed with the installation.
    else
        # Notify the user that the package is missing and will be installed.
        echo "$package not found on system, proceeding with installation."

        # Install the package using `pacman -S` (Arch Linux package manager).
        # `--noconfirm` automatically answers "yes" to prompts, allowing non-interactive installs.
        # Output is redirected to /dev/null to suppress the installation output.
        # Reference for `--noconfirm`: https://unix.stackexchange.com/questions/52277/pacman-option-to-assume-yes-to-every-question
        pacman -S --noconfirm "$package" &>/dev/null
    fi

# looping through file contents: https://stackoverflow.com/questions/1521462/looping-through-the-content-of-a-file-in-bash
done < "$file"

# Thank you to Lillian for giving me advice on things to change (No confirm and correct while loop over file)
