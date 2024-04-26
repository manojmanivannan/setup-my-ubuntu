#!/bin/bash

function setup_via_zsh4humans
{
  print_green "Setup ZSH via zsh4humans";
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)";  # https://github.com/romkatv/zsh4humans 

  append_file_content etc/zsh/.zshrc_addon $HOME/.zshrc
}

function setup_via_oh_my_zsh
{
  print_green "Installing ZSH";
  apt_get_install zsh
  echo $SUDO_PASSWORD | sudo -S chsh $USER -s $(which zsh)
  
  print_green "Installing oh-my-zsh"

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
  cp etc/zsh/.zshrc "$HOME/.zshrc"
  append_file_content etc/zsh/.zshrc_addon $HOME/.zshrc
  cp etc/zsh/amuse.zsh-theme "$HOME/.oh-my-zsh/themes/amuse.zsh-theme"

  echo "Loading GIT configuration to $HOME/.gitconfig"
  cp etc/git/.gitconfig "$HOME/.gitconfig"

  print_green "Setting up zsh plugins"
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  git clone https://github.com/unixorn/fzf-zsh-plugin.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-zsh-plugin
  git clone https://github.com/manojmanivannan/zsh-aliases-exa.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-aliases-exa
  git clone https://github.com/agkozak/zsh-z ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-z
  # git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

  print_green "Setting up Fonts"
  cd /tmp
  git clone --filter=blob:none --sparse https://github.com/ryanoasis/nerd-fonts.git
  cd /tmp/nerd-fonts
  git sparse-checkout add patched-fonts/JetBrainsMono && ./install.sh JetBrainsMono
  it sparse-checkout add patched-fonts/CascadiaCode && ./install.sh CascadiaCode
  cd "$(dirname "$ROOT_DIR")"
  rm -rf /tmp/nerd-fonts

  print_green "ZSH setup complete. LOG OFF AND LOG BACK IN to have zsh in your SHELL"
}

function setup_terminal
{
  apt_add_repo ppa:gnome-terminator
  apt_get_install terminator
}
