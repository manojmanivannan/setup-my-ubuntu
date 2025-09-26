#!/bin/bash

function setup_vscode
{
  print_green "Setting up VS code"
  # Install Visual Studio Code

  # create non-interactive way to proceed using env variables
  if [[ -n "$VSCODE_INSTALL_FROM_SNAP" ]]; then
    if [[ "$VSCODE_INSTALL_FROM_SNAP" == "true" ]]; then
      yn="y"
      INSTALL_FROM_SNAP=1
    else
      yn="n"
      INSTALL_FROM_SNAP=0
    fi

  else
    echo -en "Do you want to install vscode from snap ?(recommended) [Y/n]: "
    read yn
  fi

  case $yn in
    [Yy]*) echo $SUDO_PASSWORD | sudo -S snap install --classic code ;;
    [Nn]*) 
      setup_vscode_dependencies
      apt_get_update;
      apt_get_install code ;;
  esac
}

function setup_vscode_dependencies
{
  print_green "Setting up dependencies for VS code"
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg;
  echo $SUDO_PASSWORD | sudo -S install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg;
  cat <<EOF > /etc/apt/sources.list.d/microsoft.list
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF;
      rm -f microsoft.gpg
}
function setup_sublime_text
{
  print_green "Setting up Sublime text"

  echo -en "Do you want to install Sublime text and Sublime merge from snap ? [Y/n]: "
  read yn
  case $yn in
    [Yy]*)
      echo $SUDO_PASSWORD | sudo -S snap install --classic sublime-text ;
      echo $SUDO_PASSWORD | sudo -S snap install --classic sublime-merge ;;
    [Nn]*) 
      apt_get_install dirmngr gnupg ca-certificates ;
      wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null ;
      echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list ;
      apt_get_update ;
      apt_get_install sublime-text sublime-merge ;;
  esac
}