#!/bin/bash

query=$(echo "$1" | tr '[:upper:]' '[:lower:]')

debug=false

function setInput {
	/usr/local/bin/ddcctl -d "$1" -i "$2"
}

function setBrightness {
	if [ "$2" -gt "100" ]; then
		printft "\nERROR: Brightness cannot be greater than 100.\n\n"
	else
		/usr/local/bin/ddcctl -d "$1" -b "$2"
	fi
}

function setContrast {
	if [ "$2" -gt "100" ]; then
		printft "\nERROR: Contrast cannot be greater than 100.\n\n"
	else
		/usr/local/bin/ddcctl -d "$1" -c "$2"
	fi
}


numDisplays=$(/usr/local/bin/ddcctl 2>/dev/null | grep 'I:' | cut -c 10-10)

if [ "$debug" = 'true' ]; then
	printf '\nFound %s displays\n' "$numDisplays"
fi

if [ "$query" = 'work' ]; then

	input='17' # HDMI
	contrast='75'

	if [ "$debug" = 'true' ]; then
		printf 'Determined input should be set to HDMI (%s)\n' "$input"
		printf 'Determined contrast should be set to %s\n' "$contrast"
	fi
elif [ "$query" = 'mac' ]; then

	input='49' # USB-C
	contrast='100'

	if [ "$debug" = 'true' ]; then
		printf 'Determined input should be set to USB-C (%s)\n' "$input"
		printf 'Determined contrast should be set to %s\n' "$contrast"
	fi
fi

for display in $(seq 1 "$numDisplays")
do
	if [ "$debug" = 'true' ]; then
		printf '\nSetting display %s to input %s\n\n' "$display" "$input"
		setInput "$display" "$input"
	else
		setInput "$display" "$input" > /dev/null
	fi
done

sleep 2

for display in $(seq 1 "$numDisplays")
do
	if [ "$debug" = 'true' ]; then
		printf '\nSetting display %s contrast to %s\n\n' "$display" "$contrast"
		setContrast "$display" "$contrast"
	else
		setContrast "$display" "$contrast" > /dev/null
	fi
done

if [ "$debug" != 'true' ]; then
	echo "Set input and contrast for $numDisplays displays."
fi
