#!/usr/bin/env bash
# script to setup ssh on someone's computer with limited linux knowledged
# curl -L https://raw.githubusercontent.com/lbesnard/dotfiles/master/bin/ssh_init.sh | bash

set -e
sudo apt-get -y install openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh

mkdir -p $HOME/.ssh -m 700;
curl -L https://github.com/lbesnard.keys -o ~/.ssh/id_rsa.pub;
chmod 644 $HOME/.ssh/id_rsa.pub;
echo 'ssh key for lbesnard initialised'
