#!/bin/bash

#
# This scripts will remove mq container
# and the IMAGE for Oracle
#

getContainerId() {
	echo $(sudo podman ps | grep ora | cut -c 1-3)
}

getContainerIdNotRunning() {
	echo $(sudo podman ps -a | grep ora | cut -c 1-3)
}

chk=0

contid=$(getContainerId)

if [ "$contid" != "" ]; then
	chk=1
	echo $(date): The container is running with Id = $contid .Removing old Oracle installation ...
	sudo podman stop $contid
	sudo podman rm $contid
	sudo podman volume rm oradata1
	sudo podman volume rm shareora
else
	#Check if the container is not running
	contid=$(getContainerIdNotRunning)
	if [ "$contid" != "" ]; then
		chk=1
		echo $(date): The container is NOT running with Id = $contid .Removing old Oracle installation ...
		sudo podman rm $contid
		sudo podman volume rm oradata1
		sudo podman volume rm shareora
	fi
fi

contid=$(sudo podman image list | grep ora | awk '{ print $3 }')
if [ "$contid" != "" ]; then
	echo $(date): Removing image ID = $contid
	sudo sudo podman image rm $contid
else
	echo $(date): There is no image for Oracle..
	if [ $chk -eq 0 ]; then

		l=$(sudo podman volume list | grep -E "oradata1|shareora")

		if [ "$l" != "" ]; then
			echo $(date): Removing volumes: $(sudo podman volume list)
			sudo podman volume rm oradata1
			sudo podman volume rm shareora
		fi

	fi
fi
