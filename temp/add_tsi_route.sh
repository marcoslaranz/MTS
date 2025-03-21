#!/bin/bash

froute=$1

while IFS= read -r LINE; do
	if echo "$LINE" | grep -q "RGW_OUTQ"; then
		# Get the COMMAND from column 17.
		comm=$(echo "$LINE" | awk -F | '{ gsub(/ /,"",$17); print $17 }' | sed 's/ //g')

		if [ ${#comm} -gt 5 ]; then
			comm="TSA"
		fi

		if [ "$comm" == "#SP" ]; then
			comm="TSI"
		fi

		tailLine=" | *FT||TSI1_OUTQ|"$comm/F %TIM""

		echo "$LINE"$tailLine

	else
		echo "$LINE"
	fi
done <"$froute"
