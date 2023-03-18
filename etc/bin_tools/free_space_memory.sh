#!/bin/bash

read -p "Free up memory?[y/n] " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
echo "*"
echo "* Cleaning memory"
echo "*"
sync; 
echo 3 > /proc/sys/vm/drop_caches
fi

CONTAINERS_ON=$(docker ps | grep -v 'CONTAINER ID')
if [[ ! -z "$CONTAINERS_ON" ]]
then 
echo
docker ps
echo
read -p "Stop,remove all docker volumes/containers?[y/n] " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
echo "*"
echo "* Removing all docker volumes/system (docker system/volumne prune)"
echo "*"
docker stop $(docker ps -a -q)
docker system prune -f
docker volume prune -f
fi
fi

IMAGES_ON=$(docker images | grep -v 'REPOSITORY')
if [[ ! -z "$IMAGES_ON" ]]
then
echo
docker images
echo
read -p "Remove all docker images?[y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
echo "*"
echo "* Removing all docker images (docker rmi \$(docker images -a -q))"
echo "*"
docker rmi --force $(docker images -a -q)
fi
fi

#LXCS_ON=$(lxc-ls --fancy | grep -v 'STATE' | grep -v 'template-automation')
#if [[ ! -z "$LXCS_ON" ]]
#then
#echo
#lxc-ls --fancy | grep -v 'template'
#echo 
#read -p "Remove all lxc containers?[y/n]" -n 1 -r
#echo    # (optional) move to a new line
#if [[ $REPLY =~ ^[Yy]$ ]]
#then
#echo "*"
#echo "* Removing all lxc containers"
#echo "*"

#for each in $(lxc-ls --fancy | grep -v 'template' | grep -v 'NAME' | awk '{print $1}')
#do 
#echo "Stopping $each"
#lxc-stop --name "$each"
#echo "Destroying $each"
#lxc-destroy --name "$each"
#done

#fi
#fi
