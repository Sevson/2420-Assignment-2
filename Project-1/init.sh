#!/bin/bash

# The shebang (#!) at the start of this file specifies the interpreter to use when executing the script.
# In this case, '/bin/bash' specifies the script should be executed using the Bash shell.
# This is critical for compatibility across Unix-like systems.
# Reference: https://linuxize.com/post/bash-shebang/

# Script Handler
# --------------
# This script manages system setup tasks by running installation and configuration scripts as specified by user options.
# It checks if the user is running the script as root, provides a menu for available options, and uses `getopts` to parse options.

# Check if the script is running as the root user.
# "$EUID" (Effective User ID) is a built-in variable in Bash that holds the numeric ID of the user running the script.
# Root's ID is 0, so if "$EUID" is not 0, the user is not root.
# To handle permissions issues, the script exits with a message to use sudo if it detects a non-root user.
# Reference: https://stackoverflow.com/questions/27669950/difference-between-euid-and-uid
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or use 'sudo -E'."
    exit 1
fi  

# Get the directory containing the script.
# `dirname` extracts the directory path from a full path.
# `realpath` converts relative paths to absolute paths.
# `"${BASH_SOURCE[0]}"` holds the path of the currently executing script, so `realpath "${BASH_SOURCE[0]}"` provides the full path to this script.
# This is useful to locate other setup files in the same directory as the script.
currentdir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

# Define the help menu as a string stored in the `menu` variable for displaying options to the user.
# `-i`: Run the packagesetup script (for installing packages).
# `-c`: Run the configsetup script (for setting up configurations).
# `-h`: Display the help menu.
menu="OPTIONS:
  -i    Run the packagesetup install script
  -c    Run the configsetup script
  -h    Print the help menu"

# Initialize `OPTIND` to 1, which is necessary for `getopts` (the option parser) to function properly.
# `OPTIND` keeps track of the index of the next argument to be processed.
# It's recommended to reset OPTIND to 1 before parsing options in any shell script.
# Reference: https://unix.stackexchange.com/questions/214141/explain-the-shell-command-shift-optind-1
OPTIND=1

# `getopts` processes command-line options `i`, `c`, and `h`, with `:` specifying no argument is required for each option.
# A colon (`:`) at the start of the options string (`:ich`) suppresses error messages from `getopts` for unrecognized options.
while getopts ":ich" opt; do
  # `case` statement processes each option as specified.
  case "${opt}" in
    # Option `-i`: Runs the packagesetup install script located in the same directory.
    # `sudo -E` ensures the current user’s environment variables are preserved when running as root.
    # `||` operator triggers an error message if the script fails, suggesting to use the script with `sudo`.
    i)
      sudo -E "$currentdir/packagesetup" || echo "Failed to run 'packagesetup'. Try using 'sudo -E ./setup -i'."
      ;;
    
    # Option `-c`: Runs the configsetup script located in the same directory.
    # The `||` operator displays an error message if the command fails.
    c)
      "$currentdir/configsetup" || echo "Failed to run 'configsetup'."
      ;;
    
    # Option `-h`: Displays the help menu by echoing the contents of the `menu` variable.
    h)
      echo "$menu"
      ;;
    
    # `*` matches any invalid option. It echoes an error message and suggests using the `-h` option for help.
    # `$OPTARG` contains the invalid option's character.
    *)
      echo "Invalid option: -$OPTARG"
      echo "Try 'setup -h' for a list of options."
      exit 1
      ;;
  esac
done

# If no options were provided, `OPTIND` will still be 1.
# This condition checks if the user ran the script without any options, and if so, displays a message with usage instructions.
if [ $OPTIND -eq 1 ]; then
  echo "No option provided. An option must be specified."
  echo "Try 'setup -h' for a list of options."
  exit 1
fi


