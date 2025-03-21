#!/bin/bash

#### this should be included in all scripts ###############
source $AREA_ROOT_DIR/scripts/libShare.sh
shname=$(getShellName $BASH_SOURCE)
showmessage() {
	showMessage "$shname $1"
}
#### this should be included in all scripts ###############

showmessage "Running ..."

if [ "$1" == "" ]; then
	showmessage "Please, provide the file name. "
	exit
fi

if [ "$2" == "bnk" ]; then
	pname="bnk_swf1_rcv"
else
	pname="cnk_swftest"
fi

fname=$1

uetr_update -fi $fname

sleep 2

#swf2load -proc cnk_swftest -f $fname
swf2load -proc $pname -f $fname
