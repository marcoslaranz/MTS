#!/bin/bash
#
# This scripts clean the MQ container removing it
# and then create a bran new container
# at the start of this new container a script is executed
# this script configure the users: marcoslaranz and mtsadmin
# to access the QManager and then create the necessary queues
#
## Clean all ##

getContainerId() {
	echo $(podman ps | grep icr | cut -c 1-3)
}

getContainerIdNotRunning() {
	echo $(podman ps -a | grep icr | cut -c 1-3)
}

contid=$(getContainerId)

if [ "$contid" != "" ]; then
	echo $(date): The container is running with Id = $contid .Removing old MQ installation ...
	podman stop $contid
	podman rm $contid
	podman volume rm mqtest
	podman volume rm sharemq
else
	#Check if the container is not running
	contid=$(getContainerIdNotRunning)
	if [ "$contid" != "" ]; then
		echo $(date): The container is NOT running with Id = $contid .Removing old MQ installation ...
		podman rm $contid
		podman volume rm mqtest
		podman volume rm sharemq
	fi
fi
echo Creating the volumes:
podman volume create mqtest
podman volume create sharemq
## Start again ##
#podman run -d --name mq -p 1414:1414 -p 9443:9443 -v mqtest:/mnt/mqm -v /home/mtsadmin/sharemq:/opt/sharemq:z -e LICENSE=accept -e MQ_QMGR_NAME=QM1 -e MQ_DEV=false -e MQ_ADMIN_PASSWORD=passw0rd -e MQ_AP_PASSWORD=passw0rd icr.io/ibm-messaging/mq:latest

podman run -d --name mq -p 1414:1414 -p 9443:9443 -v mqtest:/mnt/mqm -v /home/mtsadmin/sharemq:/opt/sharemq:z -e LICENSE=accept -e MQ_QMGR_NAME=SERVQM -e MQ_DEV=false -e MQ_ADMIN_PASSWORD=passw0rd -e MQ_AP_PASSWORD=passw0rd icr.io/ibm-messaging/mq:latest

#podman run -d --name mq -p 1414:1414 -p 9443:9443 -v mqtest:/mnt/mqm -v /home/mtsadmin/sharemq/startup.mqsc:/mnt/mqm/startup.mqsc -e LICENSE=accept -e MQ_QMGR_NAME=QM1 -e MQ_DEV=false -e MQ_ADMIN_PASSWORD=passw0rd -e MQ_AP_PASSWORD=passw0rd icr.io/ibm-messaging/mq:latest
# the script startup.mqsc is not running automatically as it should
#podman run -d --name mq -p 1414:1414 -p 9443:9443 -v mqtest:/etc/mqm -v /home/mtsadmin/sharemq/startup.mqsc:/etc/mqm/startup.mqsc:z -e LICENSE=accept -e MQ_QMGR_NAME=QM1 -e MQ_DEV=false -e MQ_ADMIN_PASSWORD=passw0rd -e MQ_AP_PASSWORD=passw0rd icr.io/ibm-messaging/mq:latest

contid=$(getContainerId)

echo The new container was created with the following ID = $contid
#podman exec -it $contid bash
#podman exec -it $contid runmqsc QM1 -f /opt/sharemq/initqm1.txt
#podman exec $contid runmqsc QM1 -f /opt/sharemq/testqm.txt
## podman exec -it 14e tail -f /mnt/mqm/data/qmgrs/QM1/errors/AMQERR01.LOG

#/etc/mqm//startup.mqsc
