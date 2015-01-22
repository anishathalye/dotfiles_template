#!/bin/bash
i="wlan0"
cidr=$(while read y; do echo ${y%.*}".0/$(m=0; while read -n 1 x && [ $x = f ]; do m=$[m+4]; done < <(ifconfig $i | awk '/mask/             {$4=substr($4,3); print $4}'); echo $m )"; done < <(ifconfig $i | awk '/inet[ ]/{print $2}'))
myip=`ifconfig $i | grep "inet " | awk 'NR==1 {print $2}'`
echo "sudo nmap -n -T4 -PN -p9091 --exclude $myip $cidr"
sudo nmap -n -T4 -PN -p9091 --exclude "$myip" "$cidr"
