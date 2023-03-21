#!/bin/bash


function exit_on_failure
{
  local RET_CODE="$1"
  if [[ $RET_CODE -ne 0 ]]
  then
    print_red "SCRIPT FAILED"
  fi
  exit 1
}

function apt_get_update
{
  print_green "Updating APT repos"
  echo $SUDO_PASSWORD | sudo -S apt-get update -y
  exit_on_failure $?
}

function apt_get_install
{
  local PACKAGE_NAMES="$*"
  print_green "Installing $PACKAGE_NAMES"
  for PKG in $PACKAGE_NAMES; 
  do 
    text_yellow "Package: '$PKG'"  && echo $SUDO_PASSWORD | sudo -S apt-get install -qq --ignore-missing -y $PKG  || text_red "======> Unable to install '$PKG' package" && exit 1 ; exit_on_failure $?
  done


}