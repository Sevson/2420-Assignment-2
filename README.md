# 2420-Assignment-2 Shell Scripting

This repository contains two projects designed to simplify system setup and new user setup.

## Prerequisites

Please ensure the following requirements are met:

- **Operating System**: Arch Linux with Bash
- **Permissions**: Root access or `sudo` privileges to execute the scripts

## Projects Overview

### Project 1: System Configuration and Package Installation Scripts
This project automates the setup of a new system by installing specified packages and managing configuration files.

#### Script Overview
To run these scripts, you must have root privileges, either by logging in as the root user or by using `sudo`.

- **Init Script**: Manages the system setup process by running both the installation and configuration scripts, offering easy setup management.
- **Config Script**: Clones a Git repository and creates symbolic links for configuration and executable files in specified system directories.
- **Install Script**: Reads from a `packages.txt` file and installs any packages that are not already present on the system.
- **Packages File**: Lists all packages to be installed onto the system.

### Project 2: User Creation Script
This script automates the process of creating a new user on the system, including setting up the home directory, group memberships, shell preferences, and ensuring proper permissions.

---

## Project 1: System Setup Scripts

> **⚠️ Warning:** Only run the Init script and use provided options.

### Init Script
--------------
This script manages system setup tasks by running installation and configuration scripts as specified by user options. It checks if the user is running the script as root, provides a menu for available options, and uses `getopts` to parse options.

#### Key Points:
- **Root Check**: The script checks if it is being run as root. If not, it prompts the user to run it with `sudo`.
- **Menu Options**: It provides a menu with options to run the installation script (`-i`), the configuration script (`-c`), or to display the help menu (`-h`).
- **Error Handling**: The script displays an error message and exits if no valid options are provided.

#### Usage

Run both install and config setup scripts
````
sudo ./init.sh -i -c
````
Run only the install script
````
sudo ./init.sh -i
````
Show help menu
````
sudo ./init.sh -h
````

### Install Script
---------------------------
This script automates the installation of packages listed in a specified file (by default, "packages"). It reads through each line in the file, ignores blank and commented lines, checks if each package is already installed, and installs any missing packages.

#### Key Points:
- The script uses `pacman` (Arch Linux package manager) to install packages.
- It supports non-interactive installation by using `--noconfirm` to automatically answer "yes" to prompts.
- The script skips blank or commented lines in the package list, ensuring only valid package names are processed.

### Config Script
---------------------
This script automates the setup of symbolic links for configuration and executable files from a Git repository to specific directories on the user's system.

#### Key Points:
- The script allows the user to:
  - Specify a custom location to clone the repository.
  - Organize cloned files into the `~/bin` and `~/.config` directories.
- It uses Git to clone the repository and creates symbolic links for scripts, configuration files, and other necessary files.



---

## Project 2: User Creation Script

This script automates the process of creating a new user on the system. It sets up the user's home directory, adds the user to specified groups, configures their shell, and ensures proper permissions.

### Key Features:
- Creates a new user and their home directory.
- Adds the user to necessary groups.
- Configures shell preferences, such as the default shell and environment variables.
- Ensures the new user has the appropriate access rights and permissions.

Usage
````
sudo ./new_user -u <username> -s <shell> -g <group1,group2,...>
````
