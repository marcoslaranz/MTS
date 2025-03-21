#!/bin/bash

fn=$1
sc1=$2
in="/usr/local/intranet/areas/mlara_cnk/input"
qu=""
sc=""

if [ "$sc1" != "" ]; then
	sc1=$(echo $sc1 | tr '[:lower:]' '[:upper:]')
	echo $(date): Using the $sc1 as Source line
	sc=$sc1"_IN"
fi
echo $(date): The input line is: $sc

if [ "$fn" == "" ]; then
	echo $(date): Provide the input File name and Line:
	echo .
	echo $(date): "Example: snd_ftr.sh FILE CBZ"
	echo .
	echo $(date): Or
	echo .
	echo $(date): "Example: snd_ftr.sh FILE CBH"
	exit
fi

if [ ! -f $fn ]; then
	echo $(date): The file $fn does not exist !
	exit
fi

if [ "$sc1" == "CBZ" ]; then
	cp -p $fn "$in/cbz_in.dat"
	qu="CNK.6SQ.CBZ_IN_STAGE_MB"
elif [ "$sc1" == "CBH" ]; then
	cp -p $fn "$in/cbh_in.dat"
	qu="CNK.6SQ.CBH_STAGE_MB"
#qu="CNK.6SQ.CBH_IN_MB"

elif [ "$sc1" == "FCT" ]; then
	cp -p $fn "$in/fct_in.dat"
	sc="FCT1_RCV"
	qu="CNK_FCT_IN"
#qu="CNK.6SQ_FCT_STAGE_MB"
#PARAMETER_LIST: <VSTR(110)S> "MQ RECEIVE QNAME/NOTHING_IS/0/CNK_FCT_IN"
#PARAMETER_LIST: <VSTR(110)S> "MQ RECEIVE QNAME/NOTHING_IS/0/CNK_FCT_IN"
#PARAMETER_LIST: <VSTR(110)S> "MQ REPLY TO QNAME/NOTHING_IS/0/CNK.6SQ_FCT_IN_MB"
#PARAMETER_LIST: <VSTR(110)S> "MQ STAGE QNAME/NOTHING_IS/0/CNK.6SQ_FCT_STAGE_MB"
#PARAMETER_LIST: <VSTR(110)S> "MQ TRANSMIT QNAME/NOTHING_IS/0/CNK.6SQ_FCT_OUT_MB"
else
	echo $(date): Error INPUT LINE not defined !
	echo $(date): Provide the input File name and Line:
	echo .
	echo $(date): "Example: snd_ftr.sh FILE CBZ"
	echo .
	echo $(date): Or
	echo .
	echo $(date): "Example: snd_ftr.sh FILE CBH FCT"
	echo .
	exit
fi

echo $(date): Sending message to the Line: $sc
set -x
mq_tester -m SERVQM -q $qu -n -f $fn -iisi
set +x
er=$?
if [ $er -ne 0 ]; then
	echo $(date): Error: $er
	exit
fi

head -1 $fn | cut -c 1-14
linecmd -bank cnk -line $sc -sh
sleep 1
linecmd -bank cnk -line $sc -up
sleep 1
linecmd -bank cnk -line $sc -down
echo .
echo $(date): Message sent ..
sleep 3

msgp -n -a >/tmp/lasta 2>&1
trn=$(grep Last: /tmp/lasta | awk -F: '{ print $2 }' | sed 's/ //g')
echo Transaction: $trn
