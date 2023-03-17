#!/bin/bash


INSTALL=0
UPDATE=0

function do_header
{
  printf "%0$(tput cols)d" 0|tr '0' '='
  echo ""
  echo "$*"
  printf "%0$(tput cols)d" 0|tr '0' '='
  echo ""
  echo -e "\e[39m"
}

function print_green
{
  echo -e "\e[32m"
  do_header $*
}

function print_red
{
  echo -e "\e[31m"
  do_header $*
}


while [ "$#" -gt 0 ]; do
  case $1 in
    --install)
      INSTALL=1
      ;;
    --update)
      UPDATE=1
      ;;
  --argument1)
      shift
      GIT_REPO_URL=$1
      ;;
  --argument2)
      shift
      GET_VERSION_ONLY=1
      ;;
    *)
      echo "Unknown parameter: $1"
      exit 1
      ;;
  esac

  shift
done



#####################################
#        UPDATE SYSTEM              #
#####################################

if [ ${UPDATE} -eq 1 ]
then
    print_green "Updating system"
    sudo apt-get -y update
fi

#####################################
#       INSTALL COMMON LIBS         #
#####################################

if [ ${INSTALL} -eq 1 ]
then
    print_green "Installing Essentials"
    sudo apt-get -y install \
                   git \
                   curl \
                   wget
fi

#####################################
#       INSTALL ZSH SHELL          #
#####################################

if [ ${INSTALL} -eq 1 ]
then
    print_green "Setup ZSH"
    echo "How do you wish to install ZSH?"
    options=("zsh4humans" "oh-my-zsh" "quit")
    select opt in "${options[@]}"; do
        case $opt in
            "zsh4humans" ) print_green "Setup ZSH via zsh4humans";
                  sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)";  # https://github.com/romkatv/zsh4humans 
                  break;;
            "oh-my-zsh" ) print_green "Setup ZSH via oh-my-zsh";
                  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)";
                  break;;
            "q" ) exit;;
            * ) echo "Invalid input. Please select 1, 2, or q.";;
        esac
    done
    
fi
