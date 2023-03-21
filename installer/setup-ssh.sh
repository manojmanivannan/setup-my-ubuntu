#!/bin/bash


function setup_ssh_key
{
  echo -e "\nEnter your email ID for ssh key setup (Uses empty passphrase): "
  read EMAIL_ID
  ssh-keygen -t rsa -b 2048 -C "$EMAIL_ID" -f $HOME/.ssh/id_rsa
  exit_on_failure $? "Failed to generate ssh keys"
}