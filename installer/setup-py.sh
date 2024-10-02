#!/bin/bash

function setup_py_env
{
  # PYTHON RELATED SETUP
  print_green "Setting up PyENV"
  apt_get_install build-essential libffi-dev libssl-dev libbz2-dev libreadline-dev libsqlite3-dev liblzma-dev python3-tk tk-dev python3-pip python3-venv
  pip_install inquirer
  if [ -d "$HOME/.pyenv" ]; then
    rm -rf "$HOME/.pyenv"
  fi
  curl https://pyenv.run | bash
  exit_on_failure $? "Failed to setup PyENV"

  TARGET_PROFILE="$HOME/.zshrc"

  if ! [[ -f $TARGET_PROFILE ]]
  then
    TARGET_PROFILE="$HOME/.bashrc"
  fi

  if ! grep -q 'export PYENV_ROOT' "$TARGET_PROFILE"
  then 
    echo 'export PYENV_ROOT=$HOME/.pyenv' >> "$TARGET_PROFILE"
    echo 'command -v pyenv >/dev/null || export PATH=$PYENV_ROOT/bin:$PATH' >> "$TARGET_PROFILE"
    echo 'eval "$(pyenv init -)"' >> "$TARGET_PROFILE"
    echo 'eval "$(pyenv virtualenv-init -)"' >> "$TARGET_PROFILE"
  fi

}
