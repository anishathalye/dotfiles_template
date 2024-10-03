#!/bin/bash

cd "$(dirname "$0")/alacritty"

make app
cp -r target/release/osx/Alacritty.app /Applications/
sudo tic -xe alacritty,alacritty-direct extra/alacritty.info

# Alacritty shell completions
# See: https://github.com/alacritty/alacritty/blob/master/INSTALL.md#zsh

# Create the directory for Alacritty shell completions if it doesn't already exist.
if [ ! -d ${ZDOTDIR:-~}/.zsh_functions ]; then
    mkdir ${ZDOTDIR:-~}/.zsh_functions
    cp extra/completions/_alacritty ${ZDOTDIR:-~}/.zsh_functions/_alacritty
fi

