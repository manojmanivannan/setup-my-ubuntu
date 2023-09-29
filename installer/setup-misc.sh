#!/bin/bash

function setup_vlc
{
    print_green "Setting up VLC media player"
    apt_get_install vlc
}

function setup_obs
{
    print_green "Setting up OBS"
    apt_add_repo ppa:obsproject/obs-studio
    apt_get_install ffmpeg obs-studio

}