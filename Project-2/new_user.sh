#!/bin/bash

# https://tldp.org/LDP/sag/html/adduser.html used this to start

# Checking if the script is run with root privileges by evaluating $EUID (Effective User ID).
# $EUID will be 0 for the root user. If not, the script will display an error and exit.
# This is important because creating users and modifying system files requires root access.
# https://tldp.org/LDP/abs/html/internalvariables.html#EUID
if [[ "$EUID" -ne 0 ]]; then
    echo "Please run as root"
    exit 1
fi

# Variables for the username, shell, and groups to add
username=""
shell="/bin/bash"
group_add=()

# Function to handle errors. Takes an error message and exit status code as arguments.
# Displays the error message and exits with the specified status.
# https://linuxize.com/post/bash-functions/
error_exit() {
    echo "Error: $1"
    exit "$2"
}

# Function to find the next available UID for the new user.
# The 'awk' command parses /etc/passwd, finds the highest UID >= 1001, and adds 1 to it.
# This ensures the new user gets a unique UID, following the Linux convention to start user UIDs at 1001.
# https://www.cyberciti.biz/faq/understanding-etcpasswd-file-format/
# https://www.cbtnuggets.com/blog/technology/system-admin/linux-file-permission-uid-vs-gid
check_uid() {
    new_UID=$(awk -F: '$3 >= 1001 {uid=$3} END {print uid+1}' /etc/passwd)
    GID=$new_UID
}

# Function to add a new user.
# Checks if the specified username already exists by looking in /etc/passwd.
# If it doesn't exist, appends a new entry for the user with UID, GID, and shell.
# https://linuxize.com/post/bash-add-user-script/
add_user() {
    if grep -q "$username:" /etc/passwd; then
        error_exit "User $username already exists." 1
    else
        home_dir="/home/$username"
        echo "$username:x:$new_UID:$GID:User Account:$home_dir:$shell" >> /etc/passwd
        echo "$username:x:$GID:$username" >> /etc/group
        mkdir -p "$home_dir"
        cp -r /etc/skel/. "$home_dir"
        chown -R "$username" "$home_dir"
    fi
}

# Function to add the new user to additional groups if specified.
# Checks if each group exists in /etc/group. If it does, appends the username to that group.
# https://www.geeksforgeeks.org/group-management-in-linux/
add_group() {
    for group in "${group_add[@]}"; do
        if ! grep -q "^$group:" /etc/group; then
            error_exit "Group $group does not exist." 3
        fi
        group_line=$(grep "^$group:" /etc/group)
        if [[ $group_line =~ :$ ]]; then
            add_usergroup="${group_line}${username}"
        else
            add_usergroup="${group_line},${username}"
        fi
        sed -i "s/$group_line/$add_usergroup/" /etc/group
    done
}

# Parsing command-line arguments using getopts.
# The user can provide options for username (-u), shell (-s), and groups (-g).
# getopts is a built-in utility for parsing positional parameters in a structured way.
# https://wiki.bash-hackers.org/howto/getopts
while getopts ":u:s:g:" opt; do
    case "${opt}" in
        u)
            username=${OPTARG}
            if [[ -z "$username" ]]; then
                error_exit "Option -u requires a username." 2
            fi
            ;;
        s)
            shell=${OPTARG}
            if ! grep -Fxq "$shell" /etc/shells; then
                error_exit "$shell is not a valid shell option." 2
            fi
            ;;
        g)
            if [[ -z "${OPTARG}" ]]; then
                error_exit "Option -g requires at least one group." 2
            fi
            IFS="," read -r -a group_add <<< "${OPTARG}"
            if [[ ${#group_add[@]} -eq 0 ]]; then
                error_exit "Option -g requires at least one group." 2
            fi
            ;;
        :)
            error_exit "Option -${OPTARG} requires an argument." 2
            ;;
        *)
            error_exit "Usage: sudo ./new_user -u username -s shell -g group" 1
            ;;
    esac
done

# Ensuring that the username is provided.
if [[ -z "$username" ]]; then
    error_exit "Username is required." 1
fi

# Run functions to check UID, add the user, and add to groups.
check_uid
add_user
echo "Adding User: $username"
add_group
echo "Adding User: $username to specified groups"

# Setting the password for the new user.
# The `passwd` command will prompt for input directly in the terminal.
passwd "$username"
if [[ $? -eq 0 ]]; then
    echo "User has been created successfully."
    exit 0
else
    echo "User was created, but the password was not set."
    echo "Please set the password manually using: passwd $username"
    exit 3
fi
