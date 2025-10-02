#!/bin/bash



function install_misc()
{

    ################################################################
    # Install eza (a modern replacement for ls)
    ###############################################################

    # if eza is already installed, skip installation
    if command -v eza >/dev/null 2>&1; then
        print_yellow "eza is already installed, skipping installation"
    else
        print_green "Installing eza (a modern replacement for ls)"
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        apt_get_update
        apt_get_install eza
    fi

    ################################################################
    # Setup virtual environment for misc scripts
    ###############################################################
    print_green "Setting virtual environment + scripts in ~/.scripts"
    # if directory ~/.scripts/.venv already exists, then skip creating venv
    if [[ -d ~/.scripts/.venv ]]; then
        print_yellow "Virtual environment already exists, skipping creation"
    else
        print_green "Creating virtual environment"
        mkdir -p ~/.scripts
        python3 -m venv ~/.scripts/.venv
    fi

    ~/.scripts/.venv/bin/pip install git+https://github.com/manojmanivannan/py-file-select.git
    ~/.scripts/.venv/bin/pip install git+https://github.com/manojmanivannan/py-file-opener.git

    #################################################################
    # Install gh (GitHub CLI)
    #################################################################
    if command -v gh >/dev/null 2>&1; then
        print_yellow "GitHub CLI (gh) is already installed, skipping installation"
        gh auth status
        if [[ $? -ne 0 && -f ~/.github/token ]]; then
            print_green "Authenticating gh"
            gh auth login --with-token < ~/.github/token
        fi
    else
        print_green "Installing GitHub CLI (gh)"
        (type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
            && sudo mkdir -p -m 755 /etc/apt/keyrings \
            && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
            && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
            && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
            && sudo mkdir -p -m 755 /etc/apt/sources.list.d \
            && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        apt_get_update
        apt_get_install gh

        
        if [[ -f ~/.github/token ]]; then
            print_green "Authenticating gh"
            gh auth login --with-token < ~/.github/token
        fi
    fi



    #################################################################
    # Install rclone
    #################################################################
    if command -v rclone >/dev/null 2>&1; then
        print_yellow "rclone is already installed, skipping installation"
    else
        print_green "Installing rclone"
        curl https://rclone.org/install.sh > install-rclone.sh
        chmod +x install-rclone.sh
        echo $SUDO_PASSWORD | sudo -S ./install-rclone.sh
    fi

    #################################################################
    # Install Kopia
    #################################################################
    if command -v kopia >/dev/null 2>&1; then
        print_yellow "Kopia is already installed, skipping installation"
    else
        print_green "Installing Kopia"
        curl -s https://kopia.io/signing-key | sudo gpg --dearmor -o /etc/apt/keyrings/kopia-keyring.gpg
        echo "deb [signed-by=/etc/apt/keyrings/kopia-keyring.gpg] http://packages.kopia.io/apt/ stable main" | sudo tee /etc/apt/sources.list.d/kopia.list
        apt_get_update
        apt_get_install kopia

        if [[ -f ~/.config/kopia/kopia-policy.json ]]; then
            print_green "Setting up Kopia configuration"
            kopia --config-file=$HOME/.config/kopia/repository.config policy import --from-file $HOME/.config/kopia/kopia-policy.json --global
        fi
    fi
}