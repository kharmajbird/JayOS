#!/bin/sh

EYE=/root/bin/lfs
CANDY=/root/bin/JayOS

# Everybody likes candy
if [ -f $EYE ]; then xv -quit -max +noresetroot -root $EYE; fi
sleep 4
xv -quit -max +noresetroot -root $CANDY &

# reprioritize X11
#for i in "X " xfs; do 
#    renice -15 -p `ps ax| grep $i| awk '{print $1}'`
#done

# Kill any leftover session daemons
ps ax| grep dbus-daemon| grep session >/dev/null
if [ $? = "0" ]; then
	kill `ps ax| grep dbus-daemon| grep session| awk '{ print $1 }'`
fi

# Start the D-BUS session daemon
eval `dbus-launch`
export DBUS_SESSION_BUS_ADDRESS

gkrellm &
xdaliclock -24 -transparent -foreground white -noseconds -geometry 293x92-3+34 &
xset s off
xmodmap -e "pointer = 2 3 1"
setxkbmap -option terminate:ctrl_alt_bksp

test "`cat /proc/cmdline |grep myparm`" == ""
if [ $? -eq 1 ]; then
	xmessage "processed myparm in .xinitrc"
fi

fvwm95
killall -9 FvwmButtons
