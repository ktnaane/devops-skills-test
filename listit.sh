#!/bin/bash

touch directories.list
ls -d /* > directories.list
sed -i "1s/^/line one's line\n/" directories.list

head -3 directories.list

if [ "$#" -ne  "0" ]; then
  i=1
  while [ $i -lt $1 ]; do 
      head -3 directories.list
      i=$[$i+1]
  done
fi
