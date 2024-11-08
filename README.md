# 2420-Assignment-2 Shell Scripting

This repository contains two projects designed to simplify system setup and user management tasks.

- **Project 1:** System Configuration and Package Installation Scripts
- **Project 2:** User Creation Script

## Prerequisites

Please ensure the following requirements are met:

- **Operating System:** Arch Linux with Bash
- **Permissions:** Root access or `sudo` privileges to execute the scripts

## Project 1: System Setup Scripts

This project automates the setup of a new system by installing specified packages and managing configuration files.

### Script Overview

> **Note:** To run these scripts, you **must** have root privileges, either by logging in as the root user or by using `sudo`.

- **Init Script:** Manages the system setup process by running both the installation and configuration scripts, offering easy setup management.
- **Config Script:** Clones a Git repository and creates symbolic links for configuration and executable files in specified system directories.
- **Install Script:** Reads from a `packages.txt` file and installs any packages that are not already present on the system.
- **Packages File:** Lists all packages to be installed onto the system.

## Project 2: User Creation Script

This script automates the process of creating a new user on the system, including setting up the home directory, group memberships, and shell preferences, and ensuring proper access control.
