```md
# Debugging MTS Java on Linux

We can utilise several options for the inaugural MTS process. Below, I will go over some of the options I have employed.

## Option 1: Debugging with JDB
When MTS is up and running, check the process that you want to debug:
```bash
$ ent p
```

Then, kill the process and start it in debug mode.  
Open a new **telnet** session, then connect to the process using JDB.  
- Add to JDB the path where your **source code** is.  
- Add to JDB where the **binaries and libraries** that the process uses are.  

## Option 2: Debugging with ECOBOL Debug Port
Set the debug port and start the process in debug mode:
```bash
$ export ECOBOL_DEBUG_PORT=12345
$ soa_server -rmt api1_soa_1 -line api1_soa_1 -debug
```

Redirect JDB output to a file:
```bash
$ jdb -attach 12345 | tee jdb_output.log
```

## Option 3: Debugging Java with JDB
Start Java debug using JDB:

1. **Compile your code with debug information** (`-g` flag):
```bash
$ javac -g CLASSNAME.JAVA
```

2. **Run the application with debugging enabled**:
```bash
$ java -agentlib:jdwp=transport=dt_socket,server=y,suspend=y CLASSNAME
```

The above command will display a port number; use another session to connect to that port:
```bash
$ jdb -attach PORTNUMBER # this should be 'jdb' not 'java'
```

### Common JDB Commands:
```bash
main[1] stop at classname: LINE
main[1] run
main[1] list
main[1] print var
main[1] set var=VALUE
main[1] print var
main[1] next
```
```
