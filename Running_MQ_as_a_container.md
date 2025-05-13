# Running MQ as a Container with MTS in VirtualBox VM

## Version Control
- **Created by:** Marcos Lara  
- **Version:** 001 – Draft Version  
- **Date:** 21-Mar-2025  

## Objective
This guide provides detailed steps for configuring **MQ to run in a container** on a VirtualBox VM with Red Hat 8.

### **Notes**
- If you have already created your **Red Hat 8 VM**, some steps can be skipped.
- This guide is intended for **testing** on a development machine to simplify integration tests with MTS.
- The steps are based on memory and require validation through testing.

---

## **Setting Up the Environment**
### **Install VirtualBox VM with Red Hat 8**
1. Create a **user**: `mtsadmin`
2. Create a **group**: `mts`
3. Add user `mtsadmin` to the group `mts`
4. Disable the password for the `"Wheel"` group
5. **Login** to the VM as `mtsadmin`

### **Create a Shared Directory**
```bash
$ mkdir ~/shared
$ cd ~/shared
```
This directory will be used as a shared space between **Red Hat 8** and the **MQ container**.

---

## **Creating Initialization Scripts**
### **Files in the Shared Directory**
```bash
[mtsadmin@localhost shared]$ ls -ltr
total 16
startup.mqsc
```

### **MQ Container Cleanup & Restart Script**
Create the following script in the **HOME** directory of `mtsadmin`:
```bash
[mtsadmin@localhost scripts]$ cat mq_clean_restart.sh
#!/bin/bash
# Cleans existing MQ container and creates a new instance

### Clean all ##
getContainerId() {
    echo $(podman ps | grep icr | cut -c 1-3)
}
getContainerIdNotRunning() {
    echo $(podman ps -a | grep icr | cut -c 1-3)
}
contid=$(getContainerId)

if [ "$contid" != "" ]; then
    echo "$(date): Container is running with ID = $contid. Removing old MQ installation..."
    podman stop $contid
    podman rm $contid
    podman volume rm mqtest
    podman volume rm sharemq
else
    # Check if the container is not running
    contid=$(getContainerIdNotRunning)
    if [ "$contid" != "" ]; then
        echo "$(date): Container is NOT running with ID = $contid. Removing old MQ installation..."
        podman rm $contid
        podman volume rm mqtest
        podman volume rm sharemq
    fi
fi

echo "Creating the volumes:"
podman volume create mqtest
podman volume create sharemq

## Start new MQ container ##
podman run -d --name mq -p 1414:1414 -p 9443:9443 \
    -v mqtest:/mnt/mqm \
    -v /home/mtsadmin/sharemq:/opt/sharemq:z \
    -e LICENSE=accept \
    -e MQ_QMGR_NAME=SERVQM \
    -e MQ_DEV=false \
    -e MQ_ADMIN_PASSWORD=passw0rd \
    -e MQ_AP_PASSWORD=passw0rd \
    icr.io/ibm-messaging/mq:latest

contid=$(getContainerId)
echo "New MQ container created with ID = $contid"
```

---

## **Startup MQ Configuration Script**
Create the following **MQ startup script**:
```bash
[mtsadmin@localhost shared]$ cat startup.mqsc
DEFINE LISTENER(LISTENER) TRPTYPE(TCP) CONTROL(QMGR) PORT(1414) REPLACE
START LISTENER(LISTENER)

DEF CHL(SWIFT.CH) CHLTYPE(SVRCONN) REPLACE
SET CHLAUTH(SWIFT.CH) TYPE(USERMAP) CLNTUSER('mtsadmin') USERSRC(CHANNEL) DESCR('Allow mtsadmin user to connect') ACTION(REPLACE)
SET AUTHREC OBJTYPE(QMGR) PRINCIPAL('mtsadmin') AUTHADD(ALL)
SET AUTHREC PROFILE(*) OBJTYPE(QUEUE) PRINCIPAL('mtsadmin') AUTHADD(ALL)
REFRESH SECURITY(*) TYPE(CONNAUTH)
```

---

## **Next Steps**
### **Accessing MQ**
- **Using Command Line**:
  ```bash
  podman exec -it mq runmqsc SERVQM
  ```

- **Using MQ Explorer**:
  - If already installed, use the GUI.
  - Alternatively, **run MQ Explorer as a container** and access via a browser.

### **Database Operations**
- **Exporting data from MTS database**
- **Loading files into the RGW database**

---

