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
interval=0.5
kill_interval=5
INCLUSIONS=()

log() {
    echo "[subzero] $*"
}

die() {
    echo "[subzero][ERROR] $*" >&2
    exit 1
}

check_env() {
    command -v xdotool >/dev/null || die "xdotool not found"
}

is_included() {
    local cmd="$1"
    for ex in "${INCLUSIONS[@]}"; do
        [[ "$cmd" == "$ex" ]] && return 0
    done
    return 1
}

set_inclusions(){
if [ ! -z "$1" ];then
	log "Setting inclusions $@"
	INCLUSIONS=($@)
fi
}

get_pid_cmd() {
    local pid="$1"
    ps -p "$pid" -o comm= 2>/dev/null || echo ""
}

get_active_pid() {
    xdotool getwindowfocus getwindowpid 2>/dev/null || echo ""
}

stop_all_async (){
	log Stop shed $1 $2
     [ -z "$1" ] && return 1
     sleep $kill_interval
     local cur="$(get_active_pid)"
     if  [ $? -eq 0 ] && [ ! -z $cur ] && [ "$1" != "$cur" ]  ; then
       if  ps -p "$1" >/dev/null 2>&1; then
	local name=$(get_pid_cmd "$1")      
	log "Stopping all "$1" "$name""
	pkill -P "$1" --signal STOP
        kill -STOP "$1" >/dev/null 2>&1
       fi
     fi
}


cont_process(){
	[ -z "$1" ] && return 1
	log "Unfreezing "$1" "$2""
	pkill -P "$1" --signal CONT >/dev/null 2>&1 
	kill -CONT "$1"  >/dev/null 2>&1 
}

normal (){
check_env
set_inclusions $@
while true 
   do 
	cur="$(get_active_pid)"
	name="$(get_pid_cmd $cur)"
	prevname="$(get_pid_cmd $prev)"
     if   [ $? -eq 0 ] && [ ! -z $cur ] && [ "$prev" != "$cur" ]; then
	log "Window: $name ($cur)"
	is_included "${name}" && cont_process "$cur" "$name" 
	is_included "${prevname}" && stop_all_async "$prev" "$prevname"
	prev=$cur
     fi
     sleep $interval
   done
 }


unfreeze (){
while true 
   do 
	cur="$(get_active_pid)"
	     if  [ $? -eq 0 ] && [ "$prev" != "$cur" ]; then
	       if  ps -p "$cur" >/dev/null 2>&1; then
		cont_process "$cur" &
	       fi
	       prev=$cur
	     fi
     sleep $interval
   done
 }


# Run whatever you want  
# e.g. subzero.sh normal firefox
# or subzero.sh unfreeze
#
"$@"
