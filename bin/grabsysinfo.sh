#!/bin/bash
# grabsysinfo.sh - A simple menu driven shell script to to get information about your
# Linux server / desktop.
# Author: Vivek Gite
# Date: 12/Sep/2007

# Define variables
LSB=/usr/bin/lsb_release

# Purpose: Display pause prompt
# $1-> Message (optional)
function pause(){
    local message="$@"
    [ -z $message ] && message="Press [Enter] key to continue..."
    read -p "$message" readEnterKey
}

# Purpose  - Display a menu on screen
function show_menu(){
    date
    echo "---------------------------"
    echo "   Main Menu"
    echo "---------------------------"
    echo "1. Operating system info"
    echo "2. Hostname and dns info"
    echo "3. Network info"
    echo "4. Who is online"
    echo "5. Last logged in users"
    echo "6. Free and used memory info"
    echo "7. exit"
}

# Purpose - Display header message
# $1 - message
function write_header(){
    local h="$@"
    echo "---------------------------------------------------------------"
    echo "     ${h}"
    echo "---------------------------------------------------------------"
}

# Purpose - Get info about your operating system
function os_info(){
    write_header " System information "
    echo "Operating system : $(uname)"
    [ -x $LSB ] && $LSB -a || echo "$LSB command is not insalled (set \$LSB variable)"
    #pause "Press [Enter] key to continue..."
    pause
}

# Purpose - Get info about host such as dns, IP, and hostname
function host_info(){
    local dnsips=$(sed -e '/^$/d' /etc/resolv.conf | awk '{if (tolower($1)=="nameserver") print $2}')
    write_header " Hostname and DNS information "
    echo "Hostname : $(hostname -s)"
    echo "DNS domain : $(hostname -d)"
    echo "Fully qualified domain name : $(hostname -f)"
    echo "Network address (IP) :  $(hostname -i)"
    echo "DNS name servers (DNS IP) : ${dnsips}"
    pause
}

# Purpose - Network inferface and routing info
function net_info(){
    devices=$(netstat -i | cut -d" " -f1 | egrep -v "^Kernel|Iface|lo")
    write_header " Network information "
    echo "Total network interfaces found : $(wc -w <<<${devices})"

    echo "*** IP Addresses Information ***"
    ip -4 address show

    echo "***********************"
    echo "*** Network routing ***"
    echo "***********************"
    netstat -nr

    echo "**************************************"
    echo "*** Interface traffic information ***"
    echo "**************************************"
    netstat -i

    pause
}

# Purpose - Display a list of users currently logged on
#           display a list of receltly loggged in users
function user_info(){
    local cmd="$1"
    case "$cmd" in
        who) write_header " Who is online "; who -H; pause ;;
        last) write_header " List of last logged in users "; last ; pause ;;
    esac
}

# Purpose - Display used and free memory info
function mem_info(){
    write_header " Free and used memory "
    free -m

    echo "*********************************"
    echo "*** Virtual memory statistics ***"
    echo "*********************************"
    vmstat
    echo "***********************************"
    echo "*** Top 5 memory eating process ***"
    echo "***********************************"
    ps auxf | sort -nr -k 4 | head -5
    pause
}
# Purpose - Get input via the keyboard and make a decision using case..esac
function read_input(){
    local c
    read -p "Enter your choice [ 1 - 7 ] " c
    case $c in
        1)  os_info ;;
        2)  host_info ;;
        3)  net_info ;;
        4)  user_info "who" ;;
        5)  user_info "last" ;;
        6)  mem_info ;;
        7)  echo "Bye!"; exit 0 ;;
        *)
            echo "Please select between 1 to 7 choice only."
            pause
    esac
}

# ignore CTRL+C, CTRL+Z and quit singles using the trap
trap '' SIGINT SIGQUIT SIGTSTP

# main logic
while true
do
    clear
    show_menu   # display memu
    read_input  # wait for user input
done

