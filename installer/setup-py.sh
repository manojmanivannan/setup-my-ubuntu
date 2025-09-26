#!/bin/bash

function setup_py_env
{
  # uninstall is set, then uninstall and return
  if [[ ${UNINSTALL} -eq 1 ]]; then
    uninstall_py_env
    exit 0
  fi

  # PYTHON RELATED SETUP
  print_green "Setting up UV"
  apt_get_install build-essential libffi-dev libssl-dev libbz2-dev libreadline-dev libsqlite3-dev liblzma-dev python3-tk tk-dev python3-pip python3-venv
  pip_install inquirer

  curl -LsSf https://astral.sh/uv/install.sh | sh
  exit_on_failure $? "Failed to setup UV"

  TARGET_PROFILE="$HOME/.zshrc"

  if ! [[ -f $TARGET_PROFILE ]]
  then
    TARGET_PROFILE="$HOME/.bashrc"
  fi

  echo 'eval "$(uv generate-shell-completion zsh)"' >> "$TARGET_PROFILE"
  echo 'eval "$(uvx --generate-shell-completion bash)"' >> "$TARGET_PROFILE"

}

# Uninstall Python environment (uv)
function uninstall_py_env
{
  print_green "Uninstalling UV and cleaning up Python environment"
  # if uv is not installed, then return
  if ! command -v uv &> /dev/null
  then
    print_yellow "UV is not installed, skipping uninstallation"
    return
  fi
  uv cache clean
  rm -rf "$(uv python dir)"
  rm -rf "$(uv tool dir)"
  rm -f ~/.local/bin/uv ~/.local/bin/uvx
}
