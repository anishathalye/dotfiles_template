#!/bin/bash
#
# Start the correct autostart.*.sh script, depending on the hostname
#

hostname=`hostname`
cmd="~/.i3/scripts/autostart.common.sh"
# if [ -a "$cmd" ]; then
    eval "chmod +x $cmd"
    echo "Running $cmd..."
    eval "$cmd"
    echo "Script completed, return code $?"
# else
    echo "Script $cmd not found, skipping..."
# fi
cmd="~/.i3/scripts/autostart.$hostname.sh"
# if [ -a "$cmd" ]; then
    eval "chmod +x $cmd"
    echo "Running $cmd..."
    eval "$cmd"
    echo "Script completed, return code $?"
# else
    echo "Script $cmd not found, skipping..."
# fi
