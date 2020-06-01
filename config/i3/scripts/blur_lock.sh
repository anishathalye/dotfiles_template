#!/bin/bash
set -e
xset s off dpms 0 200 0  # It sets DPMS so the locker does not stay on forever (avoiding battery drain when just locked).

rm -f /tmp/screen_locked.png

scrot /tmp/screen_locked.png

convert /tmp/screen_locked.png -blur 0x6 /tmp/screen_locked.png

i3lock -i /tmp/screen_locked.png --show-failed-attempts --ignore-empty-password --nofork
xset s off -dpms
