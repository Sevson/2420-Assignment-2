#!/bin/bash

# Script handler - this will run both install and config for you

# Checking if script is running as root user
# https://stackoverflow.com/questions/27669950/difference-between-euid-and-uid
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or use 'sudo -E'."
    exit 1
fi  

# Get the current directory
currentdir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

menu="OPTIONS:
  -i    Run the packagesetup install script
  -c    Run the configsetup script
  -h    Print the help menu"

# Initialize OPTIND (this variable is used by getopts)
# https://unix.stackexchange.com/questions/214141/explain-the-shell-command-shift-optind-1
OPTIND=1

while getopts ":ich" opt; do
  case "${opt}" in
    i)
      # Run the install script with sudo -E if needed
      sudo -E $currentdir/packagesetup || echo "Failed to run 'packagesetup'. Try using 'sudo -E ./setup -i'."
      ;;
    c)
      # Run the config script
      $currentdir/configsetup || echo "Failed to run 'configsetup'."
      ;;
    h)
      echo "$menu"
      ;;
    *)
      echo "Invalid option: -$OPTARG"
      echo "Try 'setup -h' for a list of options."
      exit 1
      ;;
  esac
done

# Check if no options were provided and notify the user
if [ $OPTIND -eq 1 ]; then
  echo "No option provided. An option must be specified."
  echo "Try 'setup -h' for a list of options."
  exit 1
fi

