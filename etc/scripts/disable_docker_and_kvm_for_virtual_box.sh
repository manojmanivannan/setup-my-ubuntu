#!/bin/bash


sudo systemctl stop docker && sudo rmmod kvm_amd kvm

# restarting the PC will restore kvm_amd and docker
