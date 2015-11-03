#!/bin/bash

read -p "Please enter your username: " username
read -p "Please enter your password: " -s password
echo

password_md5="md5"`echo -n ${password}${username} | md5sum`
echo "Your postgres md5 encrypted password is '$password_md5'"
