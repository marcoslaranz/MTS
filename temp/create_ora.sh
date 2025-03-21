#!/bin/bash
#
# This scripts clean the Oracle container removing it
# and then create a bran-new container
# at the start of this new container a script is executed
# this script configure the users: marcoslaranz and mtsadmin
# to access the QManager and then create the necessary queues
#
## Clean all ##
contid=$(sudo podman ps | grep container | grep -i ora | cut -c 1-3)
if [ "$contid" != "" ]; then
	echo $(date): Removing old Oracle installation ...
	sudo podman stop $contid
	sudo podman container rm $contid
	sudo podman volume rm oradata1
	sudo podman volume rm shareora
else
	contid=$(sudo podman ps -a | grep container | grep -i ora | cut -c 1-3)
	if [ "$contid" != "" ]; then
		echo The container ID $contid is not active. This will be removed.
		sudo podman container rm $contid
		sudo podman volume rm oradata1
		sudo podman volume rm shareora
	fi
fi

sudo podman volume create oradata1
sudo podman volume create shareora
echo $(date): .. Starting container ..
sudo podman run -d --name OraEX -p 1521:1521 -p 5500:5500 -e ORACLE_CHARACTERSET=AL32UTF8 -e ORACLE_PWD=pass01 -v oradata1:/opt/oracle/oradata -v /home/mtsadmin/shareora:/opt/shareora:z -t container-registry.oracle.com/database/express:latest
contid=$(sudo podman ps | grep container | cut -c 1-3)
echo $(date): Container created with the following ID = $contid
sleep 30
echo $(date): Creating database.
sudo podman exec $contid sqlplus / as sysdba @/opt/shareora/startup1.sql
sleep 5
echo $(date): Grant permissions to rgwadmin user.
sudo podman exec $contid sqlplus sys/pass01@localhost/RGW as sysdba @/opt/shareora/startup2.sql
sleep 5
cd /opt/shareora/Public/RGW_6.0/xx/sql
echo $(date): Create database s objects, tables, storeprocedures, views, etc..
sudo podman exec $contid sqlplus rgwadmin/pass01@localhost/RGW @/opt/shareora/startup3.sql
echo $(date): Finished !!
