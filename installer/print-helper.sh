#!/bin/bash

source installer/font-colors.sh


function do_header
{
  printf "%0$(tput cols)d" 0|tr '0' '='
  echo ""
  echo "$*"
  printf "%0$(tput cols)d" 0|tr '0' '='
}

function print_green
{
  echo -e "${BGreen}"
  do_header $*
  echo -e "${Color_Off}"
}

function print_red
{
  echo -e "${BRed}"
  do_header $*
  echo -e "${Color_Off}"
}

function text_yellow
{
  echo -e "${BYellow}$*${Color_Off}"
}