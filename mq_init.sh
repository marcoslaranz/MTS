#!/bin/bash

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
	echo $(sudo podman ps | grep mq | cut -c 1-3)
}

contid=$(getContainerId)

echo $(date): MQ Initialization. Container ID = $contid

#Create channel

sudo podman exec -it $contid runmqsc -f /opt/sharemq/mq_init.mqsc

sleep 10

echo $(date): Creating queues.

# Create queues
sudo podman exec -it $contid runmqsc -f /opt/sharemq/queue_init.mqsc
