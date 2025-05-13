# Running RGW in a Container with MTS in VirtualBox VM

## Version Control
- **Created by:** Marcos Lara  
- **Version:** 001 – Draft Version  
- **Date:** 21-Mar-2025  

## Objective
This guide provides detailed steps for configuring **RGW to run in a container** on a VirtualBox VM.

### **Notes**
- If you have already created your **Red Hat 8 VM**, some steps can be skipped.
- This guide is part of the **MTS installation process** on VirtualBox.
- It is intended for **development testing**, simplifying integration tests with MTS.

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
This directory will be used as a shared space between **Red Hat 8** and the **RGW container**.

---

## **Preparing Scripts & SQL Files**
### **Files in the Shared Directory**
```bash
[mtsadmin@localhost shared]$ ls -ltr
total 16
startup.mqsc
startup1.sql
startup2.sql
startup3.sql
```

### **Setting Up the File Structure**
```bash
$ cd ~/shared
$ mkdir -p Public/RGW_6.0/xx/sql
```

Transfer the installation SQL scripts (`*.sql`) from your MTS RGW directory to this location:
```bash
$ scp username@hostvm:/usr/intranet/rhel74/mts/60883/sql/rgw/oracle/ddl/*.sql .
```
(*Note:* `60883` refers to an MTS **Service Pack (SP)** version number.)

---

## **Creating Initialization Scripts**
### **Creating a Cleanup & Restart Script**
```bash
[mtsadmin@localhost scripts]$ cat create_ora.sh
#!/bin/bash
# Cleans existing RGW container and creates a new instance

### Clean all ##
contid=$(sudo podman ps | grep container | grep -i ora | cut -c 1-3)
if [ "$contid" != "" ]; then
    echo "$(date): Removing old Oracle installation..."
    sudo podman stop $contid
    sudo podman container rm $contid
    sudo podman volume rm oradata1
    sudo podman volume rm shareora
else
    contid=$(sudo podman ps -a | grep container | grep -i ora | cut -c 1-3)
    if [ "$contid" != "" ]; then
        echo "$(date): Container is NOT running with ID = $contid. Removing..."
        sudo podman container rm $contid
        sudo podman volume rm oradata1
        sudo podman volume rm shareora
    fi
fi

echo "Creating the volumes:"
sudo podman volume create oradata1
sudo podman volume create shareora

## Start new RGW container ##
sudo podman run -d --name OraEX -p 1521:1521 -p 5500:5500 \
    -e ORACLE_CHARACTERSET=AL32UTF8 \
    -e ORACLE_PWD=pass01 \
    -v oradata1:/opt/oracle/oradata \
    -v /home/mtsadmin/shareora:/opt/shareora:z \
    -t container-registry.oracle.com/database/express:latest

contid=$(sudo podman ps | grep container | cut -c 1-3)
echo "New RGW container created with ID = $contid"
```

---

## **SQL Scripts for Database Setup**
### **Startup SQL for Database Creation**
```sql
-- File: startup1.sql
-- Create a database in Oracle EX edition
create pluggable database RGW admin user rgwadmin identified by pass01
    file_name_convert = ('/pdbseed/', '/rgw/');
alter pluggable database RGW open;
quit;
```

### **User Permissions & Tablespaces**
```sql
-- File: startup2.sql
grant connect to rgwadmin;
grant create view to rgwadmin;
GRANT DROP ANY view TO rgwadmin;
grant create table to rgwadmin;
GRANT DROP ANY table TO rgwadmin;
GRANT ALTER ANY table TO rgwadmin;
grant create trigger to rgwadmin;
GRANT DROP ANY trigger TO rgwadmin;
GRANT ALTER ANY trigger TO rgwadmin;

CREATE TABLESPACE MESSAGE DATAFILE 'message_datafile.dat' SIZE 10M REUSE AUTOEXTEND ON NEXT 10M MAXSIZE 200M;
CREATE TABLESPACE STATIC DATAFILE 'static_datafile.dat' SIZE 10M REUSE AUTOEXTEND ON NEXT 10M MAXSIZE 200M;

alter user rgwadmin quota unlimited on STATIC;
alter user rgwadmin quota unlimited on MESSAGE;
alter user rgwadmin quota unlimited on SYSTEM;

quit;
```

### **Executing Database Setup Scripts**
```sql
-- File: startup3.sql
@/opt/shareora/Public/RGW_6.0/xx/sql/install.sql
@/opt/shareora/Public/RGW_6.0/xx/sql/fix_rrpt_40092.sql
@/opt/shareora/Public/RGW_6.0/xx/sql/load_rrpt_reporting_total_table.sql
@/opt/shareora/Public/RGW_6.0/xx/sql/rrpt_install.sql

select object_name, object_type from user_objects where status = 'INVALID';

@/opt/shareora/Public/RGW_6.0/xx/sql/create_rrpt_process_account_info.sql
quit;
```

---

## **Opening the Database**
If you encounter issues while connecting via **Oracle SQL Developer**, run:
```bash
$ sudo podman ps
$ sudo podman exec -it <container_id> bash
$ sqlplus / as sysdba
SQL> alter pluggable database RGW open;
SQL> exit;
```

Then, test connectivity in **Oracle SQL Developer**.

---

## **Next Steps**
### **Exporting Data from MTS Database**
Run these commands to **extract** data from MTS:
```bash
$ cd ./output
$ by_logs_dmp -hist -dest -rtext -rgw -date 05-Jan-2021 -i22
```
This will generate several extracted **files**.

Convert those files for loading:
```bash
$ rgw_message today o7
$ rgw_msg_que today o7
$ rgw_adt today o7
...
```
(*Note:* These are usually managed via `./config/rgw.cfg`, but can also be run manually.)

### **Loading Files into RGW Database**
Transfer extracted files:
```bash
$ scp username@192.168.26.201:/usr/local/intranet/areas/<AREANAME>/output/*.LOAD .
```
Then, run:
```bash
$ ./load.sh
```

---

## **Final Steps**
### **Setting Up RGW Streaming in MTS**
Follow configuration steps in MTS to integrate **RGW streaming**.

---
