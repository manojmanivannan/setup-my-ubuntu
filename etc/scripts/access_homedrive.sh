#!/bin/bash

# Define mount point and share details
MOUNT_POINT="/mnt/homedrive"
SHARE="raspberrypi.local:homedrive"

# Function to mount the drive
mount_drive() {
  echo "Mounting the drive..."
  sudo mount $SHARE $MOUNT_POINT
  if [ $? -eq 0 ]; then
    echo "Drive mounted successfully at $MOUNT_POINT."
  else
    echo "Failed to mount the drive."
  fi
}

# Function to unmount the drive
umount_drive() {
  echo "Unmounting the drive..."
  sudo umount $MOUNT_POINT
  if [ $? -eq 0 ]; then
    echo "Drive unmounted successfully from $MOUNT_POINT."
  else
    echo "Failed to unmount the drive."
  fi
}

usage() {

  echo "Usage: $0 [-m|-u]"
  echo "Short script to mount the home drive $SHARE into $MOUNT_POINT"
  echo "  -m  Mount the drive"
  echo "  -u  Unmount the drive"
  exit 1
}

# Check for correct number of arguments
if [ $# -gt 1 ]; then
  echo "Error: Only one flag can be passed at a time."
  usage
fi

# Handle the flag
case $1 in
  -m)
    mount_drive
    ;;
  -u)
    umount_drive
    ;;
  *)
    echo "Invalid option: $1"
    usage
    ;;
esac



