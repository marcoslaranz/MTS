# How to read route.cfg file.

# ROUTE.CFG how to read


## Version control:

#### Created by: 	 Marcos Lara
#### When:	 30-Feb-2025.
#### Objective: Provide a step-by-step document to guide the installation of MTS on the VirtualBox machine.
#### Observation:	This is a draft version. I created this from memory, so I must perform these steps to validate the document.
#### Version:	Draft. This is under construction.

## Objective:

Provide the audience with an understanding of the file route.cfg and what customisation is necessary to ensure that the workflow of a payment message reaches its correct destination.
How to read:

The file route.cfg is read and interpreted by the program RISK_MANAGER.

## How to read:

 Like a book, there's no duplicate line from top to bottom and left to right; each column conveys a different meaning, though some columns are not used for routing transactions.

### Before you start:

Each process in the MTS has its configuration, which resides in the ENTIA database within the REMOTE_RECORD. These configurations include parameters such as which MTS queue the process should read from and what protocol the process will use. For example:

The process fmt_in (full name bnk_fmt_in, where bnk represents the first three letters of the bank name) will use the TCP/IP protocol and listen on port 89898. The majority of the processes in the MTS will be initiated by the configuration file (bash), mts.cfg, with the following line:

    iisi_main -proc bnk_fmt_in > $AREA_ROOT_DIR/logs/bnk_fmt_in_$tod.log 2>&1 &

This line will be initiated at the start of the MTS. The process **iisi_main** will examine the ENTIA database in REMOTE_RECORD using the remote record name “BNK/FMT_IN”, where all parameters will be read and executed to start the process. 

**Just note**: The remote record name convention is 1. bank’s name, 2. process’s name (usually “in”, meaning input).

	If you want to see all details of this remote record, you can run the following command:
 
	$ idi remote:”/BNK/FMT_IN” all: end:
 
Since this process will receive data from the external world of MTS via TCP/IP, you must configure a line in MTS; this line serves as the interface MTS uses to communicate with all external systems. In this context, refer to the file name line.cfg; example:

    FMT_IN,C,-
    GEN_WORK_QUE,"/BNK/MTRANS/","/BNK///FMT_IN",-
    (),-
    ()

This informs the process (fmt_in) about which line it should respect, meaning that if the line is down, no data will come into MTS through this line, and which MTS queue this line will use (FMT_IN).

	MT LINES (line.cfg), the main possible statuses are UP and DOWN.

		SWIFT LINES (Receive and send, RCV and SND)
  
		Bank back-office lines (TCP/IP), receive and send (IN and OUT)


![image](https://github.com/user-attachments/assets/ccddf8e9-69ec-4a98-a65d-b9a48f90755c)



**Note:** Each line has a process, queues, and a remote record with the associated parameters. Typically, MTS uses lines for input and other output lines (this is standard, but one line can be configured for both input and output).
Something to think about is what MTS will use to route the messages. The basics involve where the message is coming from and where it is going. In this case, MTS uses some configuration called SOURCE, CHANNEL, and specific data in the message that indicate the type of message and other parameters to route the message. Most of these parameters are configured in the file cfg_tab.dat.

## RISK manager looping

Knowing this, now is the time to learning about the looping of the RISK manager:

RISK_MANAGER is the process that reads a message in a specific queue and then reads the route.cfg to determine what message should be moved.
When a message arrives in a queue associated with a process, it starts to read and process it. When it is finished, it calls RISK_MANAGER to route the message to the next queue.
This cycle repeats until there are no more places to move the message. Example:

”Process 1” (process’s name) reads the socket TCP/IP port 89898. If something is coming, the message is parsed and moved to the MTS queue, ”Queue1”. Then, the RISK_MANAGER is called to move the message to the next queue.
After reading the route.cfg and following the rules, the RISK_MANAGER moves the message to the queue “Queue2”.
The ”Queue2” is associated to another process, (let’s say ”Process 2”), that starts as soon a message is write in this queue, the message them is processed, (some data are added others changed, others check other, so on.), when its finishes the process ”Process 2” calls RISK_MANAGER again, that will repeat the cycle above.


![image](https://github.com/user-attachments/assets/0834de92-54e5-466b-9b40-124ecd81c3d7)

## Looking at route.cfg

 ![image](https://github.com/user-attachments/assets/9eb0e54c-93d4-4af0-8cfa-d37f2141fd81)


**Note:** Only the lines that start with a pipe (|) are considered for route.cfg. Therefore, you can use any notation you prefer to add your comments as long as it does not begin with a pipe. 
If there is a symbol (@), the RISK manager continues to evaluate the sequence of lines to determine where to move the message.
In the example above, you can notice that the first column of the lines with MAP finishes with @, (at), at the end; that means the line needs to continue to be evaluated.
The @ at Func (first position) indicates that this is a continuation of the previous line. The route can move the message to one or more queues. In the example above, the MAP function routes the messages to EXCPRTQ and RGW_OUTQ.
The * means that anything is acceptable in that particular column. 
Columns:

![image](https://github.com/user-attachments/assets/fbc52d66-7acc-469c-977b-fa17bff821e3)

**1a. column: Func** (Three uppercase letters)

These functions are hardcoded into COBOL programs, which indicate what program requests the RISK manager to route the transaction, as displayed on the screen above the INQ. Depending on what the program is trying to execute, this can vary; for example, the example above requests to place a message in a queue, with the queue name at the end of the line. Some functions are also added as parameters of programs stored in the REMOTE RECORDS.
Some examples of functions are:

	CAN = Cancel; if someone is using videoclient chooses CANCEL, a transaction
	CMS = Cash Management System
	DDA = Used to post message into mainframe 
	ENQ = Enqueue message
	ENT = From SOAP – SWDL program API or type into videoclient
	SWF = A transaction coming from SWIFT
	VFY = A transaction from an action in video client that must be sent to a “Verify Queue”.

**2a.  column: Src Code** (Source Code)

The source code is defined in cfg_tab.dat. Your messages can come to MTS from many different sources, and this is used to organise the way MTS will treat each message. The source code can also be added as a parameter in the REMOTE RECORD. Some standard source codes are: SWF (when the message comes from SWIFT). 

Some examples of sources are:

	ADM = Administrative messages
	BRN = Branches
	CAI = Calypso
	SWF = Coming from a source SWIFT
**3a. Column: Tran Type** (Transaction type)

**4a. Column: Tran Type**

**5a. Column: Msg Type**

**6a. Column:  Val Dat**

**7a. Column: REP**

**8a. Column: Cdt Adv Type**

**9a. Column: Num Pty**

**10a. Column: Rsk Exc**

**11a. Column: Bank Vfc Lim**

**12a. Column: Acc Vfc Lim**

**13a. Column: rep Vfc Lim**

**14a. Column: vrs msg**

**15a. Column: fplrls**

**16a. Column: State**

**17a. Column: Cmnd**

**18a. Column: INTRTL** (Intranet Runtime Library)

  This column is customised by the COBOL code, z_bnk_cust_routing_string.cob, (where " bnk " represents the three letters of the bank).
  Based on the parameters provided to this program, it will return a string with 32 positions (more or less depending on the bank's implementation).
  Example:
 
![image](https://github.com/user-attachments/assets/4fc111dc-49e6-496f-b381-4465425232ad)


**19a. Column: Bank **

**20a. Column: Location**

**21a. Column: Qname**

**22a. Column: Bank**

**23a. Column: Prtq**














