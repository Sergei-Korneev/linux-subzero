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

     cur="$(xdotool getwindowfocus getwindowpid)"
     if ! [ "[$1" == "[$cur" ]; then

        sleep $kill_interval

       if  ps -p "$1" >/dev/null 2>&1; then
        echo Stop all async "$1"
         kill -STOP "$1" >/dev/null 2>&1
        pgrep -P "$1"  | while read F; do  kill -STOP "$F";done
       fi
     fi
}

stop_spawned_async (){

     cur="$(xdotool getwindowfocus getwindowpid)"
     if ! [ "[$1" == "[$cur" ]; then

        sleep $kill_interval

       if  ps -p "$1" >/dev/null 2>&1; then
        echo Stop spawned async "$1"
        pgrep -P "$1"  | while read F; do  kill -STOP "$F";done
       fi
     fi
}


all (){
while true 
   do 
     cur="$(xdotool getwindowfocus getwindowpid)"
     if ! [ "[$prev" == "[$cur" ]; then

       echo "
       ---
       Unfreezing "$cur"
       ---
       "

       if  ps -p "$cur" >/dev/null 2>&1; then
         kill -CONT "$cur"  >/dev/null 2>&1 
         pgrep -P "$cur"  | while read F; do  kill -CONT "$F" >/dev/null 2>&1;done
       fi
       if  ps -p "$prev" >/dev/null 2>&1; then
         kill -STOP "$prev" >/dev/null 2>&1
         pgrep -P "$prev"  | while read F; do  kill -STOP "$F" >/dev/null 2>&1;done
       fi
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

       echo "
       ---
       Unfreezing "$cur"
       ---
       "
       pgrep -P "$cur"  | while read F; do kill -CONT "$F";done
       #pgrep -P "$prev"  | while read F; do  kill -STOP "$F";done
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
       echo Unfreezing "$cur" 
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
