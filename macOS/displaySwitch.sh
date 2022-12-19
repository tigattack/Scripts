#!/bin/bash -e

query=$(echo "$1" | tr '[:upper:]' '[:lower:]')

debug=false

# https://github.com/waydabber/m1ddc
ddpath='/usr/local/bin/m1ddc'

function setInput {
	$ddpath display "$1" set input "$2"
}

function setBrightness {
	if [ "$2" -gt "100" ]; then
		printft "\nERROR: Brightness cannot be greater than 100.\n\n"
	else
		$ddpath display "$1" set luminance "$2"
	fi
}

function setContrast {
	if [ "$2" -gt "100" ]; then
		printft "\nERROR: Contrast cannot be greater than 100.\n\n"
	else
		$ddpath display "$1" contrast "$2"
	fi
}


numDisplays=$($ddpath display list 2>/dev/null | wc -l | xargs echo)

if [ $numDisplays -lt 1 ]; then
	echo "No displays found or error occured."
	exit 1
fi

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
	contrast='75'

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
	if [ $numDisplays == 1 ]; then
		echo "Set input and contrast for $numDisplays display."
	elif [ $numDisplays -gt 1 ]; then
		echo "Set input and contrast for $numDisplays displays."
	fi
fi
