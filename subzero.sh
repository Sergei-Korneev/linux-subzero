# Linux Subzero 
# Sergei Korneev, 2022


## Exit if root

[ "$EUID" == 0 ] && echo "Do not run this script as root!" &&  exit

#!/bin/bash
# Directories

export SCRIPT="$(readlink -f "${BASH_SOURCE[0]}")"
export DIR="$(dirname "$SCRIPT")"
cd "$DIR"




prev="null_"
interval=1


normal (){
while true 
   do 
     cur="$(xdotool getwindowfocus getwindowpid)"
     if ! [ "[$prev" == "[$cur" ]; then

       echo Unfreezing "$cur" 
          pgrep -P "$cur"  | while read F; do kill -CONT "$F";done
          
          if ps -p "$prev"  >/dev/null ; then
              echo Freezing "$prev"
              pgrep -P "$prev"  | while read F; do kill -STOP "$F";done
          fi

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
          pgrep -P "$prev"  | while read F; do kill -STOP "$F";done
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
