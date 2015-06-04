# Script to start programs on terminal workspace
# from https://github.com/fhaun/config-misc/blob/master/i3-stuff/auto-start-for-i3
# disable mouse while laying out windows
# mouseID=`xinput list | grep -Eo 'Mouse\s.*id\=[0-9]{1,2}' | grep -Eo '[0-9]{1,2}'`
# touchID=`xinput list | grep -Eo 'TouchPad\s*id\=[0-9]{1,2}' | grep -Eo '[0-9]{1,2}'`
# xinput set-prop $mouseID "Device Enabled" 0
# xinput set-prop $touchID "Device Enabled" 0

# maximum time to wait for a program to start
MAXWAIT=30

start() {
    eval "$@ &"                  # Handle arguments with whitspaces
    echo "$@ started, waiting for pid..."
    # mypid=$!                # Pid of last background process
    # for i in `seq $MAXWAIT` # count from 1 to MAXWAIT
    # do
    #     echo "waiting for pid $mypid..."
    # 	if xdotool search --onlyvisible --pid $mypid; then
    #         echo "pid $mypid found, returning..."
    # 	    return 0
    # 	fi
    # 	sleep 1
    # done
    # xmessage "Error on executing: $@" &
}

# wait for a class name to show up in i3 window list
wait_for_title () {
    title=$1
    for i in `seq $MAXWAIT`
    do
        echo "waiting for $title in 'i3-msg -t get_tree'..."
        if i3-msg -t get_tree | egrep "$title"; then
            echo "$title found, returning..."
            return 0
        fi
        sleep 1
    done
}

# xdg autostart (/etc/xdg/autostart and ~/.config/autostart)
dex -ae i3

# redshift
redshift-gtk &

# gollum
/home/matt/gollum.sh &
/home/matt/gollum-zenoss.sh &

# background
# feh --bg-fill --no-xinerama /home/matt/Pictures/wallpaper/abstract-sphere.jpg
feh --bg-fill --no-xinerama /home/matt/Pictures/wallpaper/nature/YS4_5968_69_70-2-3.jpg
# feh --bg-tile /home/matt/Pictures/wallpaper/pattern/stardust.png
# feh --bg-scale /home/matt/Pictures/wallpaper/Night-city-street_1920x1080.jpg

# 1: Personal
# 2: Work
## chrome has window rules
# start "google-chrome --user-data-dir=.config/google-chrome/Default"
# start "google-chrome --user-data-dir=.config/google-chrome/Profile\ 1"
dex ~/.local/share/applications/google-chrome-personal.desktop ~/.local/share/applications/google-chrome-work.desktop
wait_for_title "Google Chrome"

# 3: terminal
# byobu in upper left
i3-msg Workspace 3: terminal
# start env TERM=xterm-256color byobu
# start "dex /usr/share/applications/byobu.desktop"
start "gnome-terminal -t byobu -x byobu"
wait_for_title "matt@nova.* - byobu"
sleep 2

# terminal to matt-thinkpad
# i3-msg Workspace 3: terminal
# i3-msg split v
## provide byobu as the title so it goes to the correct workspace
# start "gnome-terminal -t byobu -x ssh matt-thinkpad"
# wait_for_title "matt@matt-thinkpad.* - byobu"
# sleep 2

# terminal to enterprise-01
# i3-msg Workspace 3: terminal
# i3-msg split v
# start "gnome-terminal -t byobu -x ssh enterprise-01"
# wait_for_title "matt@enterprise-01.* - byobu"
# sleep 2

# terminal to pegasus
i3-msg Workspace 3: terminal
# i3-msg focus left
i3-msg split v
start "gnome-terminal -t byobu -x ssh pegasus"
wait_for_title "matt@pegasus.* - byobu"
sleep 2

# 4: dev
i3-msg Workspace 4: dev
current_project="~/src/space-sim"
start "atom $current_project"
wait_for_title "Atom"
# i3-msg split h
# dex /usr/share/applications/byobu.desktop
# wait_for_title "byobu"
sleep 2

# 5: chat
i3-msg Workspace 5: chat
# skype
i3-msg split v
start "gnome-terminal -t irssi -x irssi"
wait_for_title "irssi"
sleep 2

# 7: vm
# start xp on weekdays
# if [[ $(date +%u) -lt 6 ]] ; then
#     i3-msg Workspace 7: vm
#     start "vboxmanage startvm xp"
#     wait_for_title "Oracle VM Virtualbox"
#     sleep 2
# fi

# 8: audio
# i3-msg Workspace 8: audio
# start "gnome-terminal -t pianobar -x pianobar"
# wait_for_title "pianobar"
# i3-msg split v
# sleep 2

# return to 3: terminal
i3-msg Workspace 3: terminal

# re-enable mouse
# xinput set-prop $mouseID "Device Enabled" 1
# xinput set-prop $touchID "Device Enabled" 1
