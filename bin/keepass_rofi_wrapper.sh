#!/usr/bin/env sh
# add rofi keepass
set -o allexport; . ~/.env_private; set +o allexport
set -o allexport; . ~/.env; set +o allexport
ROFI_KEEPASS_PATH=$GITHUB_DIR/rofi-keepassxc/rofi-keepassxc
$ROFI_KEEPASS_PATH -d $KEEPASS_PATH -t 6
