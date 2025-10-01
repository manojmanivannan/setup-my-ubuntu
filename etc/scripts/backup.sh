#!/bin/bash

cd "$(dirname "$0")" || exit

# Function to display usage instructions
usage() {
    echo "Usage: $0 [-l] [-u] [-r]" 1>&2
    echo "Options:" 1>&2
    echo "  -l    Backup linux machine essential files" 1>&2
    echo "  -u    Upload backup to onedrive using odc" 1>&2
    echo "  -r    Remove all old backups" 1>&2
    exit 1
}

function confirmation() {

    local message=$1
    read -p "${message} ?[y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0 ;;
        *)
            return 1 ;;
    esac
}

banner() {
    # Use environment variables if available, fallback to stty
    lines=${LINES:-$(stty size 2>/dev/null | cut -d' ' -f1)}
    cols=${COLUMNS:-$(stty size 2>/dev/null | cut -d' ' -f2)}

    # Calculate the length of the line
    line_length=$((cols - 1))

    # Print top border
    printf '=%.0s' $(seq 1 $line_length)
    printf '\n'

    # Print the backup work files section
    # Convert the input string to uppercase
    message=$(echo "$1" | tr '[:lower:]' '[:upper:]')

    # Print the converted message
    echo "$message"

    # Print bottom border
    printf '=%.0s' $(seq 1 $line_length)
    printf '\n'
}

# function banner {
#     lines=$(tput lines)
#     cols=$(tput cols)

#     # Calculate the length of the line
#     line_length=$((cols - 1))

#     printf '=%.0s' $(seq 1 $line_length)
#     printf '\n'

#     # Print the backup work files section
#     # Convert the input string to uppercase
#     message=$(echo "$1" | tr '[:lower:]' '[:upper:]')

#     # Print the converted message
#     echo "$message"

#     printf '=%.0s' $(seq 1 $line_length)
#     printf '\n'
# }

function remove_old_backup {
    local override_prompt=$1
    # Check if any backup files are present
    if ls $HOME_DIR/linux_backup*.tar.gz 1> /dev/null 2>&1; then
        # Prompt the user for confirmation
        ls $HOME_DIR/linux_backup*.tar.gz
	if [ "$override_prompt" -eq "0" ]; then
		if confirmation "Do you want to remove old backups ?"; then
			# Remove backup files if the user confirms
			rm -fv $HOME_DIR/linux_backup*.tar.gz
		fi
    else
        rm -fv $HOME_DIR/linux_backup*.tar.gz
	fi
    else
        echo "No backup files present"
    fi
}



function list_directory {
    echo "Directory included:"
    for item in "$@"; do
        if [ -d "$item" ]; then
            echo " - $item"
        fi
    done
    echo "Files included:"
    for item in "$@"; do
	if [ -f "$item" ]; then
	    echo " - $item"
	fi
    done

}
function backup_directories_and_generate_tar {
    local TAR_NAME=$1
    shift
    list_directory "$@"
    local total_size=$(du -sb "$@" | awk '{s+=$1} END {print s}')
    local total_megabytes=$(echo "scale=2; $total_size / 1048576" | bc)
    echo "Total size: $total_megabytes MB"
    tar -cf - "$@" -P | pv -s $total_size | gzip > "$TAR_NAME"
}

backup_linux=0
clean_backup=0
upload_onedrive=0
override_prompt=0

if [ "$#" -lt 1 ]; then
  usage
  exit 1
fi


while [ "$#" -gt 0 ]; do
  case $1 in
    -l)
      backup_linux=1;
      ;;
    -u)
      upload_onedrive=1;
      ;;
    -r)
      clean_backup=1;
      ;;
    -o)
      override_prompt=1;
      ;;
    *)
      echo "Unknown parameter: $1"
      usage
      exit 1
      ;;
  esac

  shift
done



RIGHT_NOW=$(date +"%Y-%m-%d-%H-%M")
HOME_DIR=/home/manoj
LINUX_BACKUP_DIR=(
    $HOME_DIR/.kube 
    $HOME_DIR/.ssh 
    $HOME_DIR/.docker 
    $HOME_DIR/.gitconfig 
    $HOME_DIR/.oh-my-zsh 
    $HOME_DIR/.local/bin 
    $HOME_DIR/.zshrc 
    $HOME_DIR/.github
    $HOME_DIR/.scripts 
    $HOME_DIR/Documents/scripts
    $HOME_DIR/Documents/vs-code-server-config 
    $HOME_DIR/.api_key
    $HOME_DIR/.config/kopia
    $HOME_DIR/.config/rclone
    /etc/systemd/system/kopia.service
)
LINUX_BACKUP_FILENAME="$HOME_DIR/linux_backup_$RIGHT_NOW.tar.gz"



if [[ ${clean_backup} -eq 1 ]]; then
    banner "Removing all backup files locally"
    remove_old_backup $override_prompt
fi

if [[ ${backup_linux} -eq 1 ]]; then
    banner "Backup linux files"
    backup_directories_and_generate_tar "$LINUX_BACKUP_FILENAME" "${LINUX_BACKUP_DIR[@]}"
fi

if [[ ${upload_onedrive} -eq 1 ]]; then
    banner "Uploading backup to onedrive"
    # for issues, check readme of https://github.com/manojmanivannan/onedrive-client
    rclone copy "$LINUX_BACKUP_FILENAME" onedrive_remote:/Documents/Manoj/BACKUPs/linux-machine -vv
    #/home/manoj/.local/bin/odc put --withprogressbar "$LINUX_BACKUP_FILENAME" /Documents/Manoj/BACKUPs/linux-machine
fi

