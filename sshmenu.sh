#!/usr/bin/env bash

# ------------------------------
# SSH List Script
# Description: This script generates a menu of SSH hosts from the SSH config file and allows the
#              user to select a host to connect to via SSH.
SSHCONFIG="${HOME}/.ssh/config"
backtitle="SSH List"
# ------------------------------

#-------------------------------
# Function to get the color set for the GUI
#     Description: This function returns the color set for the GUI based on the color label.
#     Arguments: $1 = colors_label (string) - The color label for the color set.
#     Return: The color set for the GUI. If the color label is not found, the default color set is returned.
#     Dependencies: None
#     Usage: get_colors_set "red" or get_colors_set "main"
#-------------------------------
function get_colors_set() {
  local colors_label=$1
  local color_set=""
  local default_color_set='
        root=green,black
        window=black,black
        border=green,black
        textbox=green,black
        button=brightred,black
        checkbox=green,black
        listbox=brightgreen,black
        label=green,black
        title=brightgreen,black
        compactbutton=green,black
        actsellistbox=white,black
        actlistbox=brightred,black
        shadow=black,green
        entry=green,black
        helpline=white,black
        roottext=brown,black
        '
  case $colors_label in
  "red")
    color_set='
        root=red,black
        window=black,black
        border=red,black
        textbox=red,black
        button=brightred,black
        checkbox=red,black
        listbox=brightred,black
        label=black,red
        title=brightred,black
        compactbutton=red,black
        actsellistbox=white,black
        actlistbox=brightred,black
        shadow=black,red
        entry=red,black
        helpline=white,black
        roottext=brown,black
        '
    ;;
  "brown")
    color_set='
        root=green,black
        window=black,yellow
        border=green,green
        textbox=black,yellow
        button=white,green
        checkbox=brown,black
        listbox=black,yellow
        label=green,green
        title=white,green
        compactbutton=black,yellow
        actsellistbox=white,red
        actlistbox=black,brown
        shadow=yellow,black
        entry=white,black
        helpline=white,black
        roottext=green,black
        '
    ;;
  "main" | "green" | *)
    color_set=$default_color_set
    ;;
  esac

  echo "$color_set"
}


# ------------------------------
# Function to set the colors for the GUI
# Description: Function to set the colors for the GUI
# Arguments:
#   $1 - color set (default is 1)
# Returns:
#   Exports the NEWT_COLORS variable
# Dependencies:
#   - get_colors_set
# ------------------------------
change_colors() {
    NEWT_COLORS=$(get_colors_set "$1")
    export NEWT_COLORS
}

# ------------------------------
# Function to display quit message and exit
# Description: Function to display a quit message and exit the script
# Arguments:
#   None
# Returns:
#   Displays the quit message and exits the script
# Dependencies:
#   None
# ------------------------------
function show_quit_message() {
    # shellcheck disable=SC2154
    whiptail \
        --backtitle "$backtitle" \
        --title "Quit" --msgbox "Thank you for using SSH List. Goodbye!" 10 60
    # cleanup_agent
    #exit 0
    # trigger the exit signal
    # kill -s TERM $$

    exit 0
}

# ------------------------------
# Function to display a message box
# Description: Function to display a message box with a title and message
# Arguments:
#   $1 - title: The title of the message box
#   $2 - message: The message to display in the box
#   $3 - height: The height of the message box (default is 10)
#   $4 - width: The width of the message box (default is 60)
# Returns:
#   Displays the message box
# Dependencies:
#   None
# ------------------------------
show_message() {
    local title="$1"
    local message="$2"
    local height=${3:-10}
    local width=${4:-60}
    whiptail \
        --backtitle "$backtitle" \
        --title "$title" --msgbox "$message" "$height" "$width"
}

# ------------------------------
# Function to generate the SSH menu from the SSH config file
# Description: This function reads the SSH config file and generates a menu with SSH hosts.
# Arguments:
#   $1 - ssh_config: The path to the SSH config file (default is $HOME/.ssh/config)
# Returns:
#   Populates the global associative arrays 'actions' and 'labels' with SSH host actions
#   and labels, respectively.
# Dependencies:
#   - whiptail
#   - select_menu
# ------------------------------
generate_ssh_menu() {
    local ssh_config="${1:-$HOME/.ssh/config}"
    local i=1

    # Ensure actions and labels are global
    declare -gA actions=()
    declare -gA labels=()

    while read -r host; do
        actions["$i"]="ssh $host"
        if (( i == 1 )); then
            labels["$i"]="┌──═ $host"
        else
            labels["$i"]="├──═ $host"
        fi
        ((i++))
    done < <(grep -E '^Host\s+' "$ssh_config" | grep -vE '(\*|Match)' | awk '{print $2}')

    # Add final Quit option
    actions["$i"]="exit_menu"
    labels["$i"]="└──< Quit"
}

# ------------------------------
# Function to handle the exit menu option
# Description: This function is called when the user selects the "Quit" option from the SSH menu.
# It displays a quit message and exits the script.
# Arguments:
#   None
# Returns:
#   Calls the show_quit_message function to display the quit message
# Dependencies:
#   - show_quit_message
# ------------------------------
exit_menu() {
    # shellcheck disable=SC2317
    show_quit_message
}


# ------------------------------
# Main function to handle user choice
# Description: This function displays a menu of SSH hosts and allows the user to select one to connect to.
# It uses whiptail to create a menu interface.
# Arguments:
#   None
# Returns:
#   Displays a menu and handles user selection
# Dependencies:
#   - whiptail
#   - generate_ssh_menu
#   - show_message
#   - exit_menu
# ------------------------------
select_menu() {
    local CHOICE                   # Variable to store the user choice
    local menu_options=()          # Array to store the menu options

    # Set TITLE variable
    TITLE="SSH List Menu"

    change_colors "main"

    # Store the keys in an array and sort them in ascending order
    # shellcheck disable=SC2154
    mapfile -t sorted_keys < <(printf "%s\n" "${!labels[@]}" | sort -n)

    # Iterate over the sorted keys in ascending order
    for key in "${sorted_keys[@]}"; do
        menu_options+=("$key" "${labels[$key]}")
    done

    # shellcheck disable=SC2154
    CHOICE=$(whiptail \
        --backtitle "$backtitle" \
        --title "$TITLE" \
        --nocancel \
        --clear \
        --menu "\nSelect an SSH host to connect to:\n\n" 18 100 6 \
        "${menu_options[@]}" \
        3>&1 1>&2 2>&3)

    while true; do
        # Check if the choice is valid and call the corresponding function
        if [ -n "${actions[$CHOICE]}" ]; then
            # if not the last option, call the corresponding function
            if [ "$CHOICE" -ne "${#menu_options[@]}" ]; then
                ${actions[$CHOICE]}
                select_menu
            else
                # if the last option, show a message and exit
                ${actions[$CHOICE]}
            fi
        else
            show_message "Cancelled" \
                "No valid option chosen or operation cancelled."
            select_menu
        fi
        sleep 0.5
    done
}


# ------------------------------
# Main script execution
generate_ssh_menu $SSHCONFIG
select_menu
#-------------------------------< End of script >-------------------------------