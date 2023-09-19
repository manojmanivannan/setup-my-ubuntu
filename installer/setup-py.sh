#!/bin/bash

function setup_py_env
{
  # PYTHON RELATED SETUP
  print_green "Setting up Python/PIP"
  PIP_INSTALL_FILE=/tmp/get-pip.py
  PYTHON_EXE=$(which python3)
  curl -o $PIP_INSTALL_FILE https://bootstrap.pypa.io/get-pip.py
  $PYTHON_EXE $PIP_INSTALL_FILE
  
  print_green "Setting up PyENV"
  apt_get_install build-essential libffi-dev libssl-dev libbz2-dev libreadline-dev libsqlite3-dev liblzma-dev python-tk python3-tk tk-dev
  if [ -d "$HOME/.pyenv" ]; then
    rm -rf "$HOME/.pyenv"
  fi
  curl https://pyenv.run | bash
  exit_on_failure $? "Failed to setup PyENV"
  mkdir -p $HOME/.scripts
  cd $HOME/setup-my-ubuntu
  cp etc/scripts/py_script.py $HOME/.scripts/py_script.py
}
