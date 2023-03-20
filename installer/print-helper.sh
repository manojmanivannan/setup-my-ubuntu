#!/bin/bash


function do_header
{
  printf "%0$(tput cols)d" 0|tr '0' '='
  echo ""
  echo "$*"
  printf "%0$(tput cols)d" 0|tr '0' '='
  echo -e "\e[39m"
}

function print_green
{
  echo -e "\e[32m"
  do_header $*
}

function print_red
{
  echo -e "\e[31m"
  do_header $*
}

