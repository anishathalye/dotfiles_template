#!/bin/bash
filename=$(date +%F-%T).png
scrot -s -b "/tmp/$filename"
copyq write image/png - < "/tmp/$filename"
copyq select 0
rm "/tmp/$filename"
