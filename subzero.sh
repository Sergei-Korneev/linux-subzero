# Linux Subzero 
# Sergei Korneev, 2022


## Exit if root

[ "$EUID" == 0 ] && echo "Do not run this script as root!" &&  exit

#!/bin/bash
# Directories

export SCRIPT="$(readlink -f "${BASH_SOURCE[0]}")"
export DIR="$(dirname "$SCRIPT")"
cd "$DIR"




prev="null"
interval=1
kill_interval=5

stop_all_async (){

     if [ -z "$1" ];then return 1;fi

     cur="$(xdotool getwindowfocus getwindowpid)"
     if ! [ "[$1" == "[$cur" ]; then

        sleep $kill_interval

       if  ps -p "$1" >/dev/null 2>&1; then
        echo "Stop all async "$1" "$(ps -p "$1" -o comm=)""
        notify-send "Stop all async "$1" "$(ps -p "$1" -o comm=)""
         kill -STOP "$1" >/dev/null 2>&1
        pgrep -P "$1"  | while read F; do  kill -STOP "$F";done
       fi
     fi
}

stop_spawned_async (){
     
     if [ -z :$1: ];then return 1;fi

     cur="$(xdotool getwindowfocus getwindowpid)"
     if ! [ "[$1" == "[$cur" ]; then

        sleep $kill_interval

       if  ps -p "$1" >/dev/null 2>&1; then
	       echo "Stop spawned async "$1" "$(ps -p "$1" -o comm=)""
	       notify-send "Stop spawned async "$1" "$(ps -p "$1" -o comm=)""
        pgrep -P "$1"  | while read F; do  kill -STOP "$F";done
       fi
     fi
}


all (){
while true 
   do 
     cur="$(xdotool getwindowfocus getwindowpid)"
     if ! [ "[$prev" == "[$cur" ]; then

       echo "Unfreezing "$cur" "$(ps -p "$cur" -o comm=)""
       if  ps -p "$cur" >/dev/null 2>&1; then
         kill -CONT "$cur"  >/dev/null 2>&1 
         pgrep -P "$cur"  | while read F; do  kill -CONT "$F" >/dev/null 2>&1;done
       fi
         stop_all_async "$prev"
       prev=$cur
     fi
     sleep $interval
   done
 }



normal (){
while true 
   do 
     cur="$(xdotool getwindowfocus getwindowpid)"
     if ! [ "[$prev" == "[$cur" ]; then

       echo "Unfreezing "$cur"  "$(ps -p "$cur" -o comm=)""
       pgrep -P "$cur"  | while read F; do kill -CONT "$F";done
       stop_spawned_async "$prev"
       prev=$cur
     fi
     sleep $interval
   done
 }




unfreeze (){
while true 
   do 
     cur="$(xdotool getwindowfocus getwindowpid)"

     if ! [ "[$prev" == "[$cur" ]; then
       echo "Unfreezing "$cur"  "$(ps -p "$cur" -o comm=)""
       if  ps -p "$cur" >/dev/null 2>&1; then
         kill -CONT "$cur"  >/dev/null 2>&1 
         pgrep -P "$cur"  | while read F; do  kill -CONT "$F" >/dev/null 2>&1;done
       fi
       prev=$cur
     fi
     sleep $interval
   done
 }



# Run whatewer you want  
# e.g. subzero.sh normal
# or subzero.sh unfreeze
#
"$@"
