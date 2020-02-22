#!/usr/bin/env bash
VERBOSE=0
COUNT=20

usage(){
        echo "usage: -v -c count"
        exit 1
}

log(){
        if [[ -n "$VERBOSE" ]]; then
                echo "$1 at $2."
        else
                echo "$1."
        fi
}

while getopts "c:v" opt; do
        case $opt in
        v ) VERBOSE=1 ;;
        c ) COUNT="${OPTARG}" ;;
        * ) usage ;;
        esac
done

if ! [[ $COUNT =~ ^[0-9]+$ ]]; then
        echo "not a number: $COUNT"
        exit 1
fi

prev=0
log=""
for ((i=0; i < $COUNT; i++)); do
        this=$(/usr/bin/time -p read a 2>&1 | grep real | awk '{ print $2 }')
        log="$log $this"
        if [[ $this > $prev ]]; then
                log "Good" "$this"
        else
                log "Failure" "$this"
                exit 1
        fi
        prev=$this
done
log "Win" "$this"
exit 0
