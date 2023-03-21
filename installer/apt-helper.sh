#!/bin/bash


function exit_on_failure
{
  local RET_CODE="$1"
  if [[ $RET_CODE -ne 0 ]]
  then
    print_red "Script failed"
  fi
  exit 1
}

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
    text_yellow "Package: '$PKG'"  && echo $SUDO_PASSWORD | sudo -S apt-get install -qq --ignore-missing -y $PKG  || echo -e "\e[31m ======> Unable to install '$PKG' package \e[39m"
  done


}