#!/bin/bash

function setup_vscode
{
  print_green "Setting up VS code"
  # Install Visual Studio Code
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
  echo $SUDO_PASSWORD | sudo -S install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  echo $SUDO_PASSWORD | sudo -S sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
  rm -f /tmp/packages.microsoft.gpg
  apt_get_update
  apt_get_install code
}