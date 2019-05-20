#!/bin/bash

function usage() {
	echo "keyboardctl: control X session over ssh"
	echo "usage:"
	echo " -h"
	echo "display this message"
	echo
	echo " -d display"
	echo "override display autodetection, format: ':0'"
	echo
	echo " -i"
	echo "interactive keyboard session, defaults to active window, override with -w"
	echo
	echo " -w"
	echo "window name, largest PID selected, ignored if -p is specified"
	echo
	echo " -p"
	echo "window PID"
	exit 1
}

function initialize(){
	if [[ -z "$DISPLAY" ]]; then
		DISPLAY=$(ps a | grep Xorg | sed '/grep/d' | awk '{ print $8 }') export DISPLAY
		if ! [[ "$DISPLAY" =~ ':[0-9]' ]]; then
			echo "warning: could not detect display, defaulting to :0"
			DISPLAY=:0 export DISPLAY
		fi
	fi
	if [[ -z "$WINDOW" ]]; then		
		WINDOW="$(xdotool getactivewindow)" export WINDOW
	fi
}

function getc(){
	IFS= read -r -n 1 -d '' "$@"
}

function interactive() {
	initialize
	while getc char; do
		case $char in
			" " ) input=space ;;
			"
"			    ) input=Return ;; # oh god
			'*' ) input=asterisk ;;
			'!' ) input=exclam ;;
			'@' ) input=at ;;
			'#' ) input=numbersign ;;
			'$' ) input=dollar ;;
			'%' ) input=percent ;;
			'^' ) input=INVALID ;;
			'&' ) input=ampersand ;;
			'(' ) input=parenleft ;;
			')' ) input=parenright ;;
			* )   input=$char ;;
		esac
		xdotool key --window $WINDOW $input
	done
}

while getopts "d:w:ik:" opt; do
	case ${opt} in
		d) DISPLAY=${OPTARG} export DISPLAY;;
		w) WINDOW=$(xdotool search --name ${OPTARG} | tail -n 1) export WINDOW;;
		i) interactive ;;
		k) KEY=${OPTARG} ;;
		*) usage ;;
	esac
done

initialize

xdotool key --window $WINDOW $key
