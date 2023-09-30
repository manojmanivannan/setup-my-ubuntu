#!/bin/bash

limit_mins=1440

while :
do
if [ -n "$(find /home/redbox/PS_in -prune -empty 2>/dev/null)" ]
then
  echo "empty (directory or file)"
else
  file_list="$(find /home/redbox/PS_in/  -mmin +$limit_mins -depth -print)"
  file_count="$(echo "$file_list" | wc -l)"
  if [ $file_count -gt 1 ]
  then
    echo "Contains $file_count files older than $limit_mins minutes, proceeding to delete.."
    find /home/redbox/PS_in/  -mmin +$limit_mins -delete
  else
    echo "Nothing to delete"
  fi

fi
sleep 5
done

