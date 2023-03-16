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
    apt-get -y update
fi

#####################################
#       INSTALL COMMON LIBS         #
#####################################

if [ ${INSTALL} -eq 1 ]
then
    print_green "Installing Essentials"
    apt-get -y install \
                   git \
                   curl
fi

#####################################
#       INSTALL ZSH SHELL          #
#####################################

if [ ${INSTALL} -eq 1 ]
then
    sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
    chsh -s $(which zsh) $(whoami)
fi
