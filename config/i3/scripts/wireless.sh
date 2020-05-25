#!/bin/bash

int=$(iw dev | awk '$1=="Interface"{print $2}')
openvpnFile="/home/vlp/Nextcloud/thomas/IT/vpn/fdn/fdn.ovpn"
wifiDir="/home/vlp/Nextcloud/thomas/IT/wifi/"
tmpConfFile="/tmp/tmp_conf_wifi.conf"

scan_ssid () {
	rfkill unblock wifi
	sleep 0.5
	iw dev $int scan | grep SSID
}

down_connection () {
	killall openvpn > /dev/null 2>&1
	sleep 0.5
	dhclient -r >/dev/null 2>&1
	sleep 0.5
	killall wpa_supplicant dhclient > /dev/null 2>&1
	sleep 0.5
	ip link set dev $int down
	sleep 0.5
	rfkill block wifi > /dev/null 2>&1
	sleep 0.5
	echo "Wifi stopped"
}

pre_up_connection (){
	echo "Reset connexion...."
        killall openvpn > /dev/null 2>&1
	sleep 0.5
	killall wpa_supplicant dhclient > /dev/null 2>&1
	sleep 0.5
	rfkill unblock wifi 
	sleep 0.5
	ip link set dev $int down
	sleep 0.5
	ip link set dev $int up
	sleep 0.5
	dhclient -r &>/dev/null
}

tmp_file_creation (){
	if [ -n "$" ]; then
			echo -e "network={\n\tssid=\""$1"\"\n\tkey_mgmt=WPA-PSK\n\tpsk=\""$2"\"\n}" > $tmpConfFile
	else
			echo -e "network={\n\tssid=\""$1"\"\n\tkey_mgmt=NONE\n}" > $tmpConfFile
	fi
}

connect_2_file () {
	wpa_supplicant -q -B -i $int -c $1 > /dev/null 2>&1
	sleep 0.5
	dhclient $int
	sleep 0.5
	if [ "$my_ssid" == "" ]; then my_ssid="Internet"; fi
	notify-send "Connected to: $my_ssid"
}

save_config (){
	echo "Save config in " $dirWifi "? Yes (y) or No (n)"
		read saveconfig
		if [ $saveconfig = "y" ]; then
			echo "Config file name ?"
			read file_name
			mv $tmpConfFile "$wifiDir$file_name".conf
		else	
			rm $tmpConfFile
		fi
}

help_wireless=false
down_link=false
list_ssid=false
connect_ssid=false
connect_vpn=false
saved_ssid=false

for var in "$@"
do
	if [ "$var" == "-h" ]; then help_wireless=true; fi
	if [ "$var" == "-k" ]; then down_link=true; fi
	if [ "$var" == "-l" ]; then list_ssid=true; fi
	if [ "$var" == "-c" ]; then connect_ssid=true; fi
	if [ "$var" == "-o" ]; then connect_vpn=true; fi
	if [ "$var" == "-s" ]; then saved_ssid=true; fi
done

if [ "$down_link" == "true" ]; then down_connection; fi

if [ "$list_ssid" == "true" ]; then scan_ssid; fi

if [ "$connect_ssid" == "true" ]; then 
	pre_up_connection
	echo "SSID:"
	read my_ssid
	echo "Password:"
	read my_pass
	if [ "$my_ssid" != "" ]; then
		if [ "$my_pass" == "" ]; then
			tmp_file_creation "$my_ssid"
		else
			tmp_file_creation "$my_ssid" "$my_pass"
		fi
		connect_2_file $tmpConfFile > /dev/null 2>&1
		save_config
	fi
fi

if [ "$saved_ssid" == "true" ]; then
	i=0
	for filename in "$wifiDir"*; do
			i=$((i+1))
			echo $i " - " $filename
	done
	i=0
	echo "Would you like to connect to: Number (#) or Cancel (c)"
	read connect
	if [ $connect != "c" ]; then
		for filename in "$wifiDir"*; do			
				i=$((i+1))
				if [ $i = $connect ]; then
						pre_up_connection
						connect_2_file $filename > /dev/null 2>&1
				fi
		done
	fi
fi

if [ "$connect_vpn" == "true" ]; then
	sleep 1 
	openvpn $openvpnFile &
	notify-send "Connection secured with VPN"
	sleep 3
	clear
fi

if [ "$help_wireless" == "true" ]; then
	echo "How to:"
	echo "Show available networks                    : -l"
	echo "Show saved networks & connect              : -s"
	echo "Show saved networks & connect with openvpn : -s -o"
	echo "Connect to nework                          : -c "
	echo "Connect to nework  with openvpn            : -c -o"
	echo "Shutdown wireless                          : -k"
fi
