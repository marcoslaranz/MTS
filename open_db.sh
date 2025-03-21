#!/bin/bash

#
# This scripts clean the MQ container removing it
# and then create a bran new container
# at the start of this new container a script is executed
# this script configure the users: marcoslaranz and mtsadmin
# to access the QManager and then create the necessary queues
#
## Clean all ##
contid=$(sudo podman ps | grep exp | cut -c 1-3)
if [ "$contid" == "" ]; then
	echo Database container is not running..
	exit
fi

sudo podman exec $contid sqlplus / as sysdba @/opt/shareora/open_db.sql
