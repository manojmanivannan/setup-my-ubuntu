#!/bin/bash



function install_misc() {

    print_green "Installing eza (a modern replacement for ls)"
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    apt_get_update
    apt_get_install eza

    print_green "Setting virtual environment + scripts in ~/.scripts"
    mkdir -p ~/.scripts
    python3 -m venv ~/.scripts/.venv
    ~/.scripts/.venv/bin/pip install git+https://github.com/manojmanivannan/py-file-select.git
    ~/.scripts/.venv/bin/pip install git+https://github.com/manojmanivannan/py-file-opener.git
}