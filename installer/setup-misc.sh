#!/bin/bash

function setup_vlc
{
    print_green "Setting up VLC media player"
    apt_get_install vlc
}