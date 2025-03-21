#!/bin/bash
#### this should be included in all scripts ###############
#
source $AREA_ROOT_DIR/scripts/libShare.sh
shname=$(getShellName $BASH_SOURCE)
showmessage() {
	showMessage "$shname $1"
}
#### this should be included in all scripts ###############

TRN1=$(ls -ltr | grep trn | tail -1 | awk '{ print $9 }' | sed 's/trn//g')

if [ "$TRN1" == "" ]; then
	echo There is no file to update.
	exit
fi

msgp $TRN1 >trn$TRN1

TRN=$(echo $TRN1 | sed 's/-///g')

idi message:$TRN all: end: >>trn$TRN1

showmessage "INF The msgp and idi message of message $TRN1 were updated into file trn$TRN1 "
