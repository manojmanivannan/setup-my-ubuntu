#!/bin/bash



function install_misc() {

    ################################################################
    # Install eza (a modern replacement for ls)
    ###############################################################

    print_green "Installing eza (a modern replacement for ls)"
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    apt_get_update
    apt_get_install eza

    ################################################################
    # Setup virtual environment for misc scripts
    ###############################################################
    print_green "Setting virtual environment + scripts in ~/.scripts"
    mkdir -p ~/.scripts

    # if directory ~/.scripts/.venv already exists, then skip creating venv
    if [[ -d ~/.scripts/.venv ]]; then
        print_yellow "Virtual environment already exists, skipping creation"
    else
        print_green "Creating virtual environment"
        python3 -m venv ~/.scripts/.venv
    fi

    ~/.scripts/.venv/bin/pip install git+https://github.com/manojmanivannan/py-file-select.git
    ~/.scripts/.venv/bin/pip install git+https://github.com/manojmanivannan/py-file-opener.git

    #################################################################
    # Install gh (GitHub CLI)
    #################################################################
    (type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
        && sudo mkdir -p -m 755 /etc/apt/keyrings \
        && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
        && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
        && sudo mkdir -p -m 755 /etc/apt/sources.list.d \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    apt_get_update
    apt_get_install gh
}