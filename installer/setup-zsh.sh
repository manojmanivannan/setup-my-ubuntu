#!/bin/bash

function setup_via_zsh4humans
{
  print_green "Setup ZSH via zsh4humans";
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)";  # https://github.com/romkatv/zsh4humans 

  append_file_content etc/zsh/.zshrc_addon $HOME/.zshrc
}

function setup_via_oh_my_zsh
{
  print_green "Installing ZSH"

  # install zsh and make it the default shell
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

  print_green "Loading zshrc configurations to $HOME/.zshrc"
  cp etc/zsh/.zshrc "$HOME/.zshrc"
  append_file_content etc/zsh/.zshrc_addon $HOME/.zshrc
  cp etc/zsh/amuse.zsh-theme "$HOME/.oh-my-zsh/themes/amuse.zsh-theme"

  print_green "Loading GIT configuration to $HOME/.gitconfig"
  cp etc/git/.gitconfig "$HOME/.gitconfig"

  print_green "Setting up zsh plugins"
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  git clone https://github.com/unixorn/fzf-zsh-plugin.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-zsh-plugin
  # git clone https://github.com/manojmanivannan/zsh-aliases-exa.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-aliases-exa
  git clone https://github.com/agkozak/zsh-z ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-z
  # git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

  print_green "Setting up Fonts"
  FONT_DIR=~/.local/share/fonts
  mkdir -p $FONT_DIR/NerdFonts
  find etc/fonts/ -type f -name "*.ttf" -exec cp {} $FONT_DIR/NerdFonts/. \;


  print_green "Installing"
  echo $SUDO_PASSWORD | sudo -S fc-cache -fv $FONT_DIR

  cd "$(dirname "$ROOT_DIR")"

  print_green "ZSH setup complete. LOG OFF AND LOG BACK IN to have zsh in your SHELL"

  # ask user if they want to load from tar ball backup
  read -p "Do you want to load from a tarball backup? (y/n) " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      # prompt the user for full path of the backup file
      TEMP_DIR=/tmp/backup_extract
      read -e -p "Enter the full path of the tarball backup file: " backup_path
      if [ -f "$backup_path" ]; then
          # extract the tarball to a temporary location /tmp/backup_extract
          mkdir -p $TEMP_DIR
          print_green "Extracting backup from $backup_path to $TEMP_DIR"
          tar -xvzf "$backup_path" -C $TEMP_DIR
          print_green "Backup extracted successfully."

          # move to that directory
          cd $TEMP_DIR
          if [ -d "$HOME/Documents" ]; then
              cp -r $TEMP_DIR/home/$USER/Documents/* $HOME/Documents/.
          fi
          if [ -d "$HOME/.ssh" ]; then
              cp -r $TEMP_DIR/home/$USER/.ssh/* $HOME/.ssh/.
          else
              mkdir -p $HOME/.ssh
              cp -r $TEMP_DIR/home/$USER/.ssh/* $HOME/.ssh/.
              chmod 700 ~/.ssh
              chmod 600 ~/.ssh/id_rsa
              chmod 644 ~/.ssh/id_rsa.pub
              chmod 600 ~/.ssh/authorized_keys
              chmod 644 ~/.ssh/known_hosts
              chmod 600 ~/.ssh/config
          fi

          if [ -d "$HOME/.docker" ]; then
              cp -r $TEMP_DIR/home/$USER/.docker/* $HOME/.docker/.
          else
              mkdir -p $HOME/.docker
              cp -r $TEMP_DIR/home/$USER/.docker/* $HOME/.docker/.
              chmod 700 ~/.docker
              chmod 600 ~/.docker/config.json
          fi
          # $HOME/.dockerhub
          if [ -d "$HOME/.dockerhub" ]; then
              cp -r $TEMP_DIR/home/$USER/.dockerhub/* $HOME/.dockerhub/.
          else
              mkdir -p $HOME/.dockerhub
              cp -r $TEMP_DIR/home/$USER/.dockerhub/* $HOME/.dockerhub/.
              chmod 700 ~/.dockerhub
          fi

          # $HOME/.github
          if [ -d "$HOME/.github" ]; then
              cp -r $TEMP_DIR/home/$USER/.github/* $HOME/.github/.
              cp $TEMP_DIR/home/$USER/.gitconfig $HOME/.gitconfig
          else
              mkdir -p $HOME/.github
              cp -r $TEMP_DIR/home/$USER/.github/* $HOME/.github/.
              cp $TEMP_DIR/home/$USER/.gitconfig $HOME/.gitconfig
              chmod 700 ~/.github
          fi

          # $HOME/.config
          if [ -d "$HOME/.config" ]; then
              cp -r $TEMP_DIR/home/$USER/.config/* $HOME/.config/.
          else
              mkdir -p $HOME/.config
              cp -r $TEMP_DIR/home/$USER/.config/* $HOME/.config/.
              chmod 700 ~/.config
          fi

          # $HOME/.api_key
          if [ -d "$HOME/.api_key" ]; then
              cp -r $TEMP_DIR/home/$USER/.api_key/* $HOME/.api_key/.
          else
              mkdir -p $HOME/.api_key
              cp -r $TEMP_DIR/home/$USER/.api_key/* $HOME/.api_key/.
              chmod 700 ~/.api_key
          fi

          # $HOME/.scripts
          if [ -d "$HOME/.scripts" ]; then
              cp -r $TEMP_DIR/home/$USER/.scripts/* $HOME/.scripts/.
          else
              mkdir -p $HOME/.scripts
              cp -r $TEMP_DIR/home/$USER/.scripts/* $HOME/.scripts/.
              chmod 700 ~/.scripts
          fi

          # $HOME/.local/bin
          if [ -d "$HOME/.local/bin" ]; then
              cp -r $TEMP_DIR/home/$USER/.local/bin/* $HOME/.local/bin/.
          else
              mkdir -p $HOME/.local/bin
              cp -r $TEMP_DIR/home/$USER/.local/bin/* $HOME/.local/bin/.
              chmod 700 ~/.local/bin
          fi


          print_green "Loaded scripts from backup $backup_path"
      fi
  fi

}

function setup_terminal
{
  apt_add_repo ppa:gnome-terminator
  apt_get_install terminator
}
