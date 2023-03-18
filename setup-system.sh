#!/bin/bash

####################################
# A script to setup some tools for
# your linux machine (ubuntu)
# 
# Date Created: 18-Mar-2023
# Author:       Manoj Manivannan
# 
####################################

ZSH_INSTALL=0
UPDATE=0
VSCODE_INSTALL=0
PYENV_INSTALL=0
JAVA_INSTALL=0
ALL_INSTALL=0
SSH_KEY_INSTALL=0
SPARK_INSTALL=0

function print_help
{
  echo -e "Automatically Setup Linux Machine
Usage:
  bash setup-system.sh [OPTIONS]

  OPTIONS:-
    --zsh         Setup zsh via zsh4humans or oh-my-zsh
    --pyenv       Setup Python version management tool PyENV
    --java        Setup Java
    --spark       Setup Apache Spark
    --vscode      Setup Microsoft Visual Studio Code
    --sshkey      Setup ssh key pair
    --all         Setup everything (same as passing all flags)
  "
}

function do_header
{
  printf "%0$(tput cols)d" 0|tr '0' '='
  echo ""
  echo "$*"
  printf "%0$(tput cols)d" 0|tr '0' '='
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

function apt_get_update
{
  print_green "Updating APT repos"
  sudo apt-get update -y
}

function apt_get_install
{
  local PACKAGE_NAMES="$*"
  print_green "Installing $PACKAGE_NAMES"
  sudo apt-get install -y $PACKAGE_NAMES

}

function setup_ssh_key
{
  echo "Enter your email ID for ssh key setup (Uses empty passphrase): "
  read EMAIL_ID
  ssh-keygen -t rsa -b 2048 -C "$EMAIL_ID" -f $HOME/.ssh/id_rsa
}
function setup_py_env
{
  # PYTHON RELATED SETUP
  print_green "Setting up PyENV"
  if [ -d "$HOME/.pyenv" ]; then
    rm -rf "$HOME/.pyenv"
  fi
  curl https://pyenv.run | bash
  mkdir -p $HOME/.scripts
  cd $HOME/setup-my-ubuntu
  cp etc/scripts/py_script.py $HOME/.scripts/py_script.py
}

function setup_vscode
{
  print_green "Setting up VS code"
  # Install Visual Studio Code
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
  rm -f /tmp/packages.microsoft.gpg
  apt_get_update
  apt_get_install code
}

function setup_java
{
  print_green "Setting up JAVA"
  apt_get_update
  apt_get_install default-jre default-jdk

  TARGET_PROFILE="$HOME/.zshrc"

  # JAVA HOME
  if [[ -z $SPARK_HOME ]]
  then 
    echo 'export JAVA_HOME=/usr/lib/jvm/default-java' >> "$TARGET_PROFILE"
    echo 'export PATH=$JAVA_HOME/bin:$PATH' >> "$TARGET_PROFILE"
  fi

}

function setup_spark
{
  local SPARK_VERSION="3.3.2"
  local HADOOP_VERSION="3"
  print_green "Setting up Spark $SPARK_VERSION with hadoop $HADOOP_VERSION"
  setup_java
  apt_get_install scala
  if ! [[ -f "$spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz" ]]
  then
    wget "https://dlcdn.apache.org/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz"
  fi
  tar xf spark-*
  sudo mv spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION /opt/spark
  rm -rf spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz
  
  TARGET_PROFILE="$HOME/.zshrc"

  if [[ -z $SPARK_HOME ]]
  then 
    echo 'export SPARK_HOME=/opt/spark' >> "$TARGET_PROFILE"
    echo 'export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin' >> "$TARGET_PROFILE"
    echo 'export PYSPARK_PYTHON=/usr/bin/python3' >> "$TARGET_PROFILE"
  fi

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
  sudo apt-get -y install zsh
  echo ""
  echo "Need permission to set zsh as default shell"
  chsh -s $(which zsh)
  
  echo "Installing oh-my-zsh"

  # If ~/.oh-y-zsh already exists, make a backup
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Backing up oh-my-zsh folder"
    mv "$HOME/.oh-my-zsh" "$HOME/.oh-my-zsh-backup-$(date +%H_%M_%d_%h_%y)"
  fi
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended ;
  print_green "oh-my-zsh install complete"

  # If ~/.zshrc already exists, make a backup
  if [ -f "$HOME/.zshrc" ]; then
    echo "Backing up $HOME/.zshrc"
    mv "$HOME/.zshrc" "$HOME/.zshrc_backup_$(date +%H_%M_%d_%h_%y)"
  fi

  echo "Loading zshrc configurations to $HOME/.zshrc"
  cp etc/.zshrc "$HOME/.zshrc"
  cp etc/amuse.zsh-theme "$HOME/.oh-my-zsh/themes/amuse.zsh-theme"

  echo "Loading GIT configuration to $HOME/.gitconfig"
  cp etc/.gitconfig "$HOME/.gitconfig"

  print_green "Setting up zsh plugins"
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  git clone https://github.com/unixorn/fzf-zsh-plugin.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-zsh-plugin
  git clone https://github.com/DarrinTisdale/zsh-aliases-exa.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-aliases-exa
  # git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

  print_green "Setting up Fonts"
  cd $HOME
  git clone --filter=blob:none --sparse https://github.com/ryanoasis/nerd-fonts.git
  cd nerd-fonts
  git sparse-checkout add patched-fonts/JetBrainsMono && ./install.sh JetBrainsMono
  cd $HOME/setup-my-ubuntu



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
#        UPDATE SYSTEM              #
#####################################

if [[ ${UPDATE} -eq 1 || ${ALL_INSTALL} -eq 1 ]]
then
    print_green "Updating system"
    echo -e "Running 'apt-get -y update' with elevated permissions"
    apt_get_update
fi

#####################################
#       INSTALL COMMON LIBS         #
#####################################

if [[ ${UPDATE} -eq 1 || ${ALL_INSTALL} -eq 1 ]]
then
    print_green "Installing Essentials"
    echo -e "Running 'apt-get -y install' with elevated permissions"
    apt_get_install git curl wget make software-properties-common gpg  apt-transport-https exa #fonts-powerline
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

print_green "FINISHED !!!"

