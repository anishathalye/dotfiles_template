#!/usr/bin/env bash
ffmpeg -f video4linux2 -i /dev/video0 -s 1280x720 -vframes 1 ~/auth`date +%Y_%m_%d_%H-%M-%S`.jpeg &>/dev/null
