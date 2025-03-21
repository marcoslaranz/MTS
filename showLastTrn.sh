#!/bin/bash
#### this should be included in all scripts ###############
source $AREA_ROOT_DIR/scripts/libShare.sh
shname=$(getShellName $BASH_SOURCE)
showmessage() {
	showMessage "$shname $1"
}
#### this should be included in all scripts ###############

showmessage "Running Showing last transactions.."

last=""
last1=""

while true; do
	msgp -n -a >/tmp/lastTrn.txt 2>&1
	last=$(grep TRN /tmp/lastTrn.txt | grep -i Last)
	if [ "$last1" != "$last" ]; then
		showmessage "Info: $last"
		last1=$last
	fi
	sleep 2
done
