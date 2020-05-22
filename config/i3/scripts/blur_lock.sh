#!/bin/bash

rm /tmp/screen_locked.png

scrot /tmp/screen_locked.png

convert /tmp/screen_locked.png -blur 0x6 /tmp/screen_locked.png

i3lock -i /tmp/screen_locked.png
