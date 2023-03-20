#!/bin/bash

source installer/print-helper.sh

function setup_docker
{
    print_green "Installing docker"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
}