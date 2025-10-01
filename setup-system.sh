#!/bin/bash

####################################
# A script to setup some tools for
# your linux machine (ubuntu)
# 
# Date Created: 18-Mar-2023
# Author:       Manoj Manivannan
# 
####################################

# set -e # Fail on any error

ROOT_DIR="$0"

source installer/setup-docker.sh
source installer/setup-editor.sh
source installer/setup-py.sh
source installer/setup-zsh.sh
source installer/setup-ssh.sh
source installer/print-helper.sh
source installer/apt-helper.sh


ESSENTIAL=0
ZSH_INSTALL=0
UPDATE=0
VSCODE_INSTALL=0
PYENV_INSTALL=0
UNINSTALL=0
ALL_INSTALL=0
SSH_KEY_INSTALL=0
DOCKER_INSTALL=0
TERMINAL_INSTALL=0
SUBLIME_TXT_INSTALL=0
LOAD_FROM_TAR=0

function print_help
{
  echo -e "Automatically Setup Linux Machine
Usage:
  ${BCyan}bash${Color_Off} ${BBlue}setup-system.sh${Color_Off} ${Yellow}[OPTIONS]${Color_Off}

  Env variables:
    ${Yellow}SUDO_PASSWORD${Color_Off}              Your sudo password (if not provided, will be prompted)
    ${Yellow}ZSH_INSTALL_TYPE${Color_Off}           Type of ZSH installation: 'zsh4humans' or 'oh-my-zsh' (if not provided, will be prompted)
    ${Yellow}VSCODE_INSTALL_FROM_SNAP${Color_Off}   Install vscode from snap if true (default: false) (if not provided, will be prompted)
    ${Yellow}SUBLIME_INSTALL_FROM_SNAP${Color_Off}  Install sublime text from snap if true (default: false) (if not provided, will be prompted)
    ${Yellow}PATH_TO_BACKUP_TAR${Color_Off}         Path to tarball backup of various configurations (if not provided, will be prompted)

  OPTIONS:
    ${Yellow}--essential${Color_Off}   Install essential packages
    ${Yellow}--zsh${Color_Off}         Setup zsh via zsh4humans or oh-my-zsh
    ${Yellow}--pyenv${Color_Off}       Setup Python environment (UV)
    ${Yellow}--vscode${Color_Off}      Setup Microsoft Visual Studio Code
    ${Yellow}--sshkey${Color_Off}      Setup ssh key pair
    ${Yellow}--docker${Color_Off}      Setup docker and docker-compose
    ${Yellow}--terminal${Color_Off}    Setup Gnome terminator
    ${Yellow}--sublt${Color_Off}       Setup Sublime text
    ${Yellow}--all${Color_Off}         Setup everything (same as passing all flags)
    ${Yellow}--load-tar${Color_Off}    Load configuration from a tarball backup
    ${Yellow}--uninstall${Color_Off}   Uninstall any packages installed via this script
  "
}



if [ "$#" -lt 1 ]; then
  print_help
  exit 1
fi

while [ "$#" -gt 0 ]; do
  case $1 in
    --essential)
      ESSENTIAL=1;UPDATE=1;
      ;;
    --zsh)
      ZSH_INSTALL=1;ESSENTIAL=1;UPDATE=1;
      ;;
    --vscode)
      VSCODE_INSTALL=1;UPDATE=1;
      ;;
    --sublt)
      SUBLIME_TXT_INSTALL=1;UPDATE=1;
      ;;
    --pyenv)
      PYENV_INSTALL=1;UPDATE=1;
      ;;
    --uninstall)
      UNINSTALL=1
      ;;
    --sshkey)
      SSH_KEY_INSTALL=1;UPDATE=1;
      ;;
    --docker)
      DOCKER_INSTALL=1;UPDATE=1;
      ;;
    --terminal)
      TERMINAL_INSTALL=1;UPDATE=1;
      ;;
    --all)
      ALL_INSTALL=1;
      ;;
    --load-tar)
      LOAD_FROM_TAR=1;
      ;;
    *)
      echo "Unknown parameter: $1"
      print_help
      exit 1
      ;;
  esac
  shift
done

#####################################
#        GET SUDO PASSWORD          #
#####################################
if [ -z "$SUDO_PASSWORD" ]; then
  echo -en "since many commands need elevated permissions\nEnter your password for '$USER' :"
  read -s SUDO_PASSWORD   
fi

function no_ctrlc()
{
    print_red "Script interrupted"
    exit
}

trap no_ctrlc SIGINT

#####################################
#        UPDATE SYSTEM              #
#####################################

if [[ ${UPDATE} -eq 1 || ${ALL_INSTALL} -eq 1 ]]
then
    print_green "Updating system"
    apt_get_update
fi

#####################################
#       INSTALL COMMON LIBS         #
#####################################

if [[ ${ESSENTIAL} -eq 1 || ${ALL_INSTALL} -eq 1 ]]
then
    print_green "Installing Essentials"
    apt_get_install_all git curl wget make software-properties-common gpg git-crypt apt-transport-https bat vim pv fontconfig pipx fd-find python3-pip python3-venv #fonts-powerline
    mkdir -p ~/.scripts
    python3 -m venv ~/.scripts/.venv
    ~/.scripts/.venv/bin/pip install git+https://github.com/manojmanivannan/py-file-select.git
    ~/.scripts/.venv/bin/pip install git+https://github.com/manojmanivannan/py-file-opener.git
fi

#####################################
#####################################
# INSTALL/UNINSTALL EVERYTHING ELSE #
#####################################


if [[ ${ZSH_INSTALL} -eq 1 || ${ALL_INSTALL} -eq 1 ]]
then
    print_green "Setup ZSH"
    # create a non-interactive way to proceed using env variables
    if [[ -n "$ZSH_INSTALL_TYPE" ]]; then
        if [[ "$ZSH_INSTALL_TYPE" == "zsh4humans" ]]; then
            setup_via_zsh4humans
        elif [[ "$ZSH_INSTALL_TYPE" == "oh-my-zsh" ]]; then
            setup_via_oh_my_zsh
        else
            print_red "Invalid ZSH_INSTALL_TYPE: $ZSH_INSTALL_TYPE. Valid options are 'zsh4humans' or 'oh-my-zsh'"
            exit 1
        fi
    else
      echo "How do you wish to install ZSH?"
      options=("zsh4humans" "oh-my-zsh" "quit")
      select opt in "${options[@]}"; do
          case $opt in
              "zsh4humans" ) setup_via_zsh4humans; break;;
              "oh-my-zsh" ) setup_via_oh_my_zsh; break;;
              "quit" ) exit;;
              * ) echo "Invalid input. Please select 1, 2, or 3";;
          esac
      done
    fi
fi

if [[ ${VSCODE_INSTALL} -eq 1 || ${ALL_INSTALL} -eq 1 ]]
then
  setup_vscode
fi

if [[ ${SUBLIME_TXT_INSTALL} -eq 1 || ${ALL_INSTALL} -eq 1 ]]
then
  setup_sublime_text
fi

if [[ ${PYENV_INSTALL} -eq 1 || ${ALL_INSTALL} -eq 1 ]]
then
  setup_py_env
fi
    
if [[ ${SSH_KEY_INSTALL} -eq 1 || ${ALL_INSTALL} -eq 1 ]]
then
  setup_ssh_key
fi

if [[ ${DOCKER_INSTALL} -eq 1 || ${ALL_INSTALL} -eq 1 ]]
then
  setup_docker
fi



if [[ ${TERMINAL_INSTALL} -eq 1 || ${ALL_INSTALL} -eq 1 ]]
then
  setup_terminal
fi

if [[ ${LOAD_FROM_TAR} -eq 1 || ${ALL_INSTALL} -eq 1 ]]
then
  setup_load_backup
fi

(trap - INT;)

print_green "FINISHED !!!"

