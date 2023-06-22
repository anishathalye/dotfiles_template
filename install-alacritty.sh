#!/bin/bash

cd "$(dirname "$0")/alacritty"

make app
cp -r target/release/osx/Alacritty.app /Applications/
sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
