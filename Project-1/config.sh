#!/bin/bash

# This script was created with the purpose of cloning a repository with existing config files and then creating symbolic links from the repository files to their intended locations.

#To-Do
# comments
# Full paths (no ~)
# Let user specify repo clone location + set default location

# Checking if git is installed on system
if [[ -e /bin/git ]]; then
  # Git is installed, Clone existing configuration files from https://gitlab.com/cit2420/2420-as2-starting-files into directory named config_files
  echo "Git is installed. Proceeding with clone."
  git clone https://gitlab.com/cit2420/2420-as2-starting-files ~/config_files 
else
  # Git is not installed
  err": You need to install git to run this script"
  exit 1
fi

# Get a list of full paths to directories in the cloned repository, excluding hidden directories
directories=$(find ~/config_files -maxdepth 1 -mindepth 1 -type d -not -path "*/.*")


# Iterate through the directories variable
for dir in $directories; do

  # Get the basename of each subdirectory found (basename is the last part of the path)
  base="${dir##*/}"

  # Check the basename against cases defined below
  case "$base" in

    # If basename == bin, iterate through the files and create symbolic links in ~/bin that point to the scripts in ~/config_files/bin directory
    bin)
      echo -e "\n$base:"
      echo ---------------------------------
      for script in $(find "$dir" -maxdepth 1 -mindepth 1 -type f); do
        base="${script##*/}" # Get the base name of the file (e.g., sayhi, install-fonts)
        ln -s "$script" "$HOME/bin" && echo "Creating symbolic link for ${base}"
      done
      ;;

    # If basename == config, iterate through its subdirectories and create symbolic links in ~/.config directory that point to the directories in ~/config_files/config directory
    config)
      echo -e "\n$base:"
      echo ---------------------------------
      for config_dir in $(find "$dir" -maxdepth 1 -mindepth 1 -type d); do
        base="${config_dir##*/}" # Get the base name of the subdirectory (e.g., kak, tmux)
        ln -s "$config_dir" "$HOME/.config" && echo "Creating symbolic link for ${base}"
      done
      ;;

    # If basename == home, iterate through the files and create symbolic links in the user's home directory that point to the files in ~/config_files/home directory
    home)
      echo -e "\n$base:"
      echo ---------------------------------
      for file in $(find "$dir" -maxdepth 1 -mindepth 1 -type f); do
        base="${file##*/}" # Get the base name of the file (e.g., bashrc)
        ln -s "$file" "$HOME/.$base" && echo "Creating symbolic link for ${base}"
      done
      ;;

    # If basename is not part of the defined case statements in this script, tell the user to edit the script
    *)
      echo -e "***\nNew directory in the repository since this script (configsetup) was last modified."
      echo "Please edit the script to accommodate it.\n***"
      ;;

  esac
done

echo "Configuration file setup complete" 
