#!/bin/bash

# This script will handle the installation of new packages onto the system
# Packages to be installed can be found in the "packages" text file

# Defining file location, this file contains packages to install
file="packages"

# Iterates through each line found in the package file
# While loop and read file
# https://www.javatpoint.com/bash-while-loop + https://www.javatpoint.com/bash-read-file
while read package; do

    # Conditional statement to check if the line is a valid line.
    # Statement will pass true if the line is empty OR the second starts with a # (a commented line) and continue
    # https://stackoverflow.com/questions/22080937/skip-blank-lines-when-iterating-through-file-line-by-line
    [[ -z "$package" || "$package" == \#* ]] && continue

    # Conditonal statement to check if the package is already installed, followed by /dev/null to discard any output
    # https://devhints.io/pacman
    if pacman -Q "$package"&>/dev/null; then
        # Output if the package is installed
        echo "$(pacman -Q "$package") is already installed."

    # If the package is not installed, continue with this block of code
    else
        # Output if the package is not installed
        echo "$package not found on system, proceeding with installation."

        # Install packages and supress output, also --noconfirm the Y/N
        # https://unix.stackexchange.com/questions/52277/pacman-option-to-assume-yes-to-every-question
	    pacman -S --noconfirm "$package" &>/dev/null
	fi

# Send the file variable into while loop
# https://stackoverflow.com/questions/1521462/looping-through-the-content-of-a-file-in-bash
done < "$file"

# Thank you to Lillian for giving me advice on things to change (No confirm and correct while loop over file)
