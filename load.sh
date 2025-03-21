#!/bin/bash
cd dat

contid=$(sudo podman ps | grep oracle | cut -c 1-3)

if [ "$contid" == "" ]; then
	echo The Oracle container was not started yet. Please start the Container before run this script.
	exit
fi

echo The container is running with the ID = $contid

for lx in $(ls); do
	dat=$(echo "$lx" | tr '[:lower:]' '[:upper:]')

	fil=$(echo "$lx" | awk -F. '{ print $1 }')

	fil=$(echo "$fil" | tr '[:upper:]' '[:lower:]')

	ctl="load_"$fil"_t.ctl"

	echo "Processing file: ctl = $ctl"
	if [ ! -f ../ctl/$ctl ]; then
		echo The file ../ctl/$ctl Does Not Exit with error. Check logs
		exit
	fi

	echo "Processing file: ctl = $dat"
	if [ ! -f $dat ]; then
		echo The file $dat Does Not Exit with error. Check logs
		exit
	fi

	bad=$fil".bad"
	log=$fil".log"

	#This works
	#sudo podman exec -it $contid sqlldr rgwadmin/pass01@localhost/RGW /opt/shareora/Public/RGW_6.0/xx/ctl/$fil log=/opt/shareora/Public/RGW_6.0/xx/logs/$fil.log bad=/opt/shareora/Public/RGW_6.0/xx/logs/$fil.bad data=/opt/shareora/Public/RGW_6.0/xx/dat/$dat

	sudo podman exec -it $contid sqlldr rgwadmin/pass01@localhost/RGW /opt/shareora/Public/RGW_6.0/xx/ctl/$ctl /opt/shareora/Public/RGW_6.0/xx/logs/$log /opt/shareora/Public/RGW_6.0/xx/logs/$bad /opt/shareora/Public/RGW_6.0/xx/dat/$dat

	sleep 2

done
