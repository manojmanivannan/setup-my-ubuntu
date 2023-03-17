#!/bin/bash


INSTALL=0
UPDATE=0

function print_help
{
  echo -e "Automatically Setup Ubuntu"
  echo -e "Usage:"
  echo -e "setup-system.sh --install --update"
}

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

function setup_py_env
{
  print_green "Setting up PyENV"
  curl https://pyenv.run | bash
}

function setup_via_zsh4humans
{
  print_green "Setup ZSH via zsh4humans";
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)";  # https://github.com/romkatv/zsh4humans 
}

function setup_via_oh_my_zsh
{
  print_green "Setup ZSH via oh-my-zsh";
  
  echo "Installing ZSH with elevated permissions"
  sudo apt-get -y install zsh;
  
  echo "Installing oh-my-zsh"
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Backing up oh-my-zsh folder"
    mv "$HOME/.oh-my-zsh" "$HOME/.oh-my-zsh-backup-$(date +%H_%M_%d_%h_%y)"
  fi
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended ;
  print_green "oh-my-zsh install complete"

  if [ -f "$HOME/.zshrc" ]; then
    echo "Backing up $HOME/.zshrc"
    mv "$HOME/.zshrc" "$HOME/.zshrc_backup_$(date +%H_%M_%d_%h_%y)"
  fi

  echo "Loading zshrc configurations to $HOME/.zshrc"
  cp etc/.zshrc "$HOME/.zshrc"

  print_green "Setting up zsh plugins"
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  git clone https://github.com/unixorn/fzf-zsh-plugin.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-zsh-plugin

  setup_py_env


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
      print_help
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
    echo -e "Running 'apt-get -y update' with elevated permissions"
    sudo apt-get -y update
fi

#####################################
#       INSTALL COMMON LIBS         #
#####################################

if [ ${INSTALL} -eq 1 ]
then
    print_green "Installing Essentials"
    echo -e "Running 'apt-get -y install' with elevated permissions"
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
            "zsh4humans" ) setup_via_zsh4humans; break;;
            "oh-my-zsh" ) setup_via_oh_my_zsh; break;;
            "quit" ) exit;;
            * ) echo "Invalid input. Please select 1, 2, or 3";;
        esac
    done
    
fi
