#!/bin/bash
#configure evoluent mouse buttons
device_id=`xinput | grep 'Evoluent' | egrep -o 'id=([0-9]*)' | cut -d'=' -f2`
xinput --set-button-map $device_id 1 3 0 4 5 0 0 0 2 0 0
