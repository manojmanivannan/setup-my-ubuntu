#!/bin/bash

function setup_docker
{
    print_green "Installing docker"
    curl -fsSL https://get.docker.com -o get-docker.sh
    echo $SUDO_PASSWORD | sudo -S sh get-docker.sh || exit_on_failure $? "Failed to install docker"
    echo $SUDO_PASSWORD | sudo -s usermod -aG docker $USER || exit_on_failure $? "Failed to assign docker in sudo group"
    rm get-docker.sh
    apt_get_install docker-compose
    exit_on_failure $? "Failed to install docker-composee"
}