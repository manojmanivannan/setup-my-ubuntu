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

source installer/setup-docker.sh
source installer/setup-vscode.sh
source installer/setup-py.sh
source installer/setup-zsh.sh
source installer/setup-java.sh
source installer/setup-ssh.sh
source installer/print-helper.sh
source installer/apt-helper.sh


ZSH_INSTALL=0
UPDATE=0
VSCODE_INSTALL=0
PYENV_INSTALL=0
JAVA_INSTALL=0
ALL_INSTALL=0
SSH_KEY_INSTALL=0
SPARK_INSTALL=0
DOCKER_INSTALL=0
TERMINAL_INSTALL=0

function print_help
{
  echo -e "Automatically Setup Linux Machine
Usage:
  ${BCyan}bash${Color_Off} ${BBlue}setup-system.sh${Color_Off} ${Yellow}[OPTIONS]${Color_Off}

  OPTIONS:
    ${Yellow}--zsh${Color_Off}         Setup zsh via zsh4humans or oh-my-zsh
    ${Yellow}--pyenv${Color_Off}       Setup Python version management tool PyENV
    ${Yellow}--java${Color_Off}        Setup Java
    ${Yellow}--spark${Color_Off}       Setup Apache Spark
    ${Yellow}--vscode${Color_Off}      Setup Microsoft Visual Studio Code
    ${Yellow}--sshkey${Color_Off}      Setup ssh key pair
    ${Yellow}--docker${Color_Off}      Setup docker and docker-compose
    ${Yellow}--terminal${Color_Off}    Setup Gnome terminator
    ${Yellow}--all${Color_Off}         Setup everything (same as passing all flags)
  "
}



if [ "$#" -lt 1 ]; then
  print_help
  exit 1
fi

while [ "$#" -gt 0 ]; do
  case $1 in
    --zsh)
      ZSH_INSTALL=1;UPDATE=1;
      ;;
    --vscode)
      VSCODE_INSTALL=1;UPDATE=1;
      ;;
    --pyenv)
      PYENV_INSTALL=1;UPDATE=1;
      ;;
    --java)
      JAVA_INSTALL=1;UPDATE=1;
      ;;
    --spark)
      SPARK_INSTALL=1;UPDATE=1;
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
echo -en "since many commands need elevated permissions\nEnter your password for '$USER' :"
read -s SUDO_PASSWORD   


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

if [[ ${UPDATE} -eq 1 || ${ALL_INSTALL} -eq 1 ]]
then
    print_green "Installing Essentials"
    apt_get_install git curl wget make software-properties-common gpg  apt-transport-https exa bat #fonts-powerline
fi

#####################################
#       INSTALL ZSH SHELL          #
#####################################

if [[ ${ZSH_INSTALL} -eq 1 || ${ALL_INSTALL} -eq 1 ]]
then
    print_green "Setup ZSH"
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

if [[ ${VSCODE_INSTALL} -eq 1 || ${ALL_INSTALL} -eq 1 ]]
then
  setup_vscode
fi

if [[ ${PYENV_INSTALL} -eq 1 || ${ALL_INSTALL} -eq 1 ]]
then
  setup_py_env
fi
    
if [[ ${JAVA_INSTALL} -eq 1 || ${ALL_INSTALL} -eq 1 ]]
then
  setup_java
fi

if [[ ${SPARK_INSTALL} -eq 1 || ${ALL_INSTALL} -eq 1 ]]
then
  setup_spark
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


(trap - INT;)

print_green "FINISHED !!!"

