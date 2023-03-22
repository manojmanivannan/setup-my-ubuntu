#!/bin/bash

function setup_via_zsh4humans
{
  print_green "Setup ZSH via zsh4humans";
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)";  # https://github.com/romkatv/zsh4humans 
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
  cp etc/.zshrc "$HOME/.zshrc"
  cp etc/amuse.zsh-theme "$HOME/.oh-my-zsh/themes/amuse.zsh-theme"

  echo "Loading GIT configuration to $HOME/.gitconfig"
  cp etc/.gitconfig "$HOME/.gitconfig"

  print_green "Setting up zsh plugins"
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  git clone https://github.com/unixorn/fzf-zsh-plugin.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-zsh-plugin
  git clone https://github.com/DarrinTisdale/zsh-aliases-exa.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-aliases-exa
  # git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

  print_green "Setting up Fonts"
  cd $HOME
  git clone --filter=blob:none --sparse https://github.com/ryanoasis/nerd-fonts.git
  cd nerd-fonts
  git sparse-checkout add patched-fonts/JetBrainsMono && ./install.sh JetBrainsMono
  cd $HOME/setup-my-ubuntu
  rm -rf $HOME/nerd-fonts

}

function setup_terminal
{
  echo $SUDO_PASSWORD | sudo -S add-apt-repository -y ppa:gnome-terminator
  apt_get_update
  apt_get_install terminator
}