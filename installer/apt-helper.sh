#!/bin/bash

function apt_get_update
{
  print_green "Updating APT repos"
  echo $SUDO_PASSWORD | sudo -S apt-get update -y
}

function apt_get_install
{
  local PACKAGE_NAMES="$*"
  print_green "Installing $PACKAGE_NAMES"
  for PKG in $PACKAGE_NAMES; 
  do 
    text_yellow "'$PKG'"  && echo $SUDO_PASSWORD | sudo -S apt-get install --ignore-missing -y $PKG  || echo -e "\e[31m ======> Unable to install '$PKG' package \e[39m"
  done


}