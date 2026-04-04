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
interval=0.4
kill_interval=5
exclusions=()


stop_all_async (){
     if [ -z "$1" ];then return 1;fi
	sleep $kill_interval
     cur="$(xdotool getwindowfocus getwindowpid)"
     if  [ "$1" != "$cur" ]; then
       if  ps -p "$1" >/dev/null 2>&1; then
        cmdline="$(ps -p "$1" -o comm= )"
        [[ "${exclusions[@]}" =~ "${cmdline}" ]] && return 0;
         echo "Stop all async "$1" "$cmdline""
	 pgrep -P "$1" --signal STOP
         kill -STOP "$1" >/dev/null 2>&1
       fi
     fi
}

stop_spawned_async (){
     if [ -z "$1" ];then return 1;fi
	sleep $kill_interval
	cur="$(xdotool getwindowfocus getwindowpid)"
	if [ "$1" != "$cur" ]; then
	if  ps -p "$1" >/dev/null 2>&1; then
		cmdline="$(ps -p "$1" -o comm= )"
		[[ "${exclusions[@]}" =~ "${cmdline}" ]] && return 0;
	       echo "Stop spawned async "$1" "$cmdline""
	pgrep -P "$1"  --signal -STOP
	fi
     fi
}

cont_process(){
	if [ -z "$1" ];then return 1;fi
	echo "Unfreezing "$1" "$(ps -p "$1" -o comm=)""
	pgrep -P "$1" --signal CONT >/dev/null 2>&1 
	kill -CONT "$1"  >/dev/null 2>&1 
}

set_exclusions(){
if [ ! -z "$1" ];then
	echo "Setting exclusions $@"
	exclusions=($@)
fi
}

all (){
set_exclusions $@
while true 
   do 
     cur="$(xdotool getwindowfocus getwindowpid)"
     if [ "$prev" != "$cur" ]; then
	cont_process "$cur" &
	stop_all_async "$prev" &
       prev=$cur
     fi
     sleep $interval
   done
 }



normal (){
set_exclusions $@
while true 
   do 
     cur="$(xdotool getwindowfocus getwindowpid)"
     if [ "$prev" != "$cur" ]; then
	cont_process "$cur" &
	stop_spawned_async "$prev" &
       prev=$cur
     fi
     sleep $interval
   done
 }




unfreeze (){
while true 
   do 
     cur="$(xdotool getwindowfocus getwindowpid)"
     if [ "$prev" != "$cur" ]; then
       if  ps -p "$cur" >/dev/null 2>&1; then
	cont_process "$cur" &
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
