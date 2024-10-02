#!/bin/bash


function exit_on_failure
{
  local RET_CODE="$1"
  local MSG="$2"
  if [[ $RET_CODE -ne 0 ]]
  then
    print_red "SCRIPT FAILED $MSG"
    exit 1
  fi
  
}

function apt_get_update
{
  print_green "Updating APT repos"
  echo $SUDO_PASSWORD | sudo -S apt-get update -y
  exit_on_failure $? "Failed to update repositories"
}

function apt_get_install
{
  local PACKAGE_NAMES="$*"
  print_green "Installing $PACKAGE_NAMES"
  for PKG in $PACKAGE_NAMES; 
  do 
    text_yellow "Package: '$PKG'"  && echo $SUDO_PASSWORD | sudo -S apt-get install -qq --ignore-missing -y $PKG  || exit_on_failure $? "Failed to install package '$PKG'"
  done


}

function pipx_install
{
  local PACKAGE_NAMES="$*"
  print_green "Installing $PACKAGE_NAMES"
  for PKG in $PACKAGE_NAMES; 
  do 
    text_yellow "Package: '$PKG'"  && pipx install $PKG --force  || exit_on_failure $? "Failed to install package '$PKG'"
  done


}

function apt_add_repo
{
  local REPO_NAMES="$*"
  print_green "Adding repositories"
  for REPO in $REPO_NAMES;
  do
    text_yellow "Repository: '$REPO'" && echo $SUDO_PASSWORD | sudo -S apt-add-repository -y $REPO
  done
  apt_get_update
}

function pip_install
{
  local PACKAGE_NAMES="$*"
  export PIP_BREAK_SYSTEM_PACKAGES=1
  print_green "Install Python package(s)"
  for PKG in $PACKAGE_NAMES;
  do
    text_yellow "Package: '$PKG'" && python3 -m pip install $PKG || exit_on_failure $? "Failed to install python package '$PKG'"
  done
}

function append_file_content
{
  local SOURCE_FILE="$1"
  local TARGET_FILE="$2"

  text_yellow "Appending contents of $SOURCE_FILE into $TARGET_FILE"
  echo "# =====================================" >> $TARGET_FILE
  echo "# ======== Added by script ============" >> $TARGET_FILE
  echo "# =====================================" >> $TARGET_FILE
  echo "$(<$SOURCE_FILE)" >> $TARGET_FILE

}
