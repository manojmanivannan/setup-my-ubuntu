#!/bin/bash

function setup_docker
{
    print_green "Installing docker"
    curl -fsSL https://get.docker.com -o get-docker.sh
    echo $SUDO_PASSWORD | sudo -S sh get-docker.sh
    echo $SUDO_PASSWORD | sudo -s usermod -aG docker $USER
    rm get-docker.sh
    apt_get_install docker-compose
}