#!/bin/bash
#
#
# **M. Lara,**
#
# Send the AK to the pacs.008 message.
#
# Here's what to check if the AK doesn't match:
#
# 1. The AK is sent to the RTI1_RCV line. Verify if this line is up and running.
# 2. Check the RTI1_SND line. Issues with the sequence number can prevent the line from going up.
# Review the logs for this line, adjust the sequence number if necessary,
# and then attempt to bring the line up.
# 3. Pending queues can obstruct message processing. Clear all messages from the pending queues.
#
# I have automated most of these checks in the scripts, but if
# errors persist, please verify those steps manually.
#
#### this should be included in all scripts ###############
source $AREA_ROOT_DIR/scripts/libShare.sh
shname=$(getShellName $BASH_SOURCE)
showmessage() {
	showMessage "$shname $1"
}
#### this should be included in all scripts ###############

dt=$(date +"%Y-%m-%dT%TZ")

step=0
trn_provided=0

area=$(area | grep area | cut -c 18- | sed 's/"//g' | sed 's/ //g' | sed 's/.//g')

if [ "$area" == "" ]; then
	showmessage "Error: AREA not found"
	exit
fi

if [ "$1" != "" ]; then
	trn_provided=1
	if [ $(echo $1 | grep "-" | wc -l) -gt 0 ]; then
		TR=$1
		TRN=$(echo $1 | sed 's/-//g' | sed 's/ //g')
	else
		TRN=$1
		TR=$(echo $1 | cut -c 1-8)"-"$(echo $1 | cut -c 9-)
	fi
else
	TR=$(getLastTrnFmt 2)
	TRN=$(getLastTrnFmt 3)
fi

showmessage "Info: - - - Sending AK to the Transaction TR = $TR - - -"

if [ -f /tmp/$TRN ]; then
	rm /tmp/$TRN
fi

msgp $TR >/tmp/$TRN

if [ $(cat /tmp/$TRN | grep "Transmission Report Received" | wc -l) -gt 0 ]; then
	echo AK already received.
	exit
fi

#
# Generating the uniq SWFREF
#
SWREF="SWI54321-"$(date | sed 's/ /-/g')"Z"

#### get Fields from original #####

for lx in $(echo SWIFTRef PseudoAckNack SenderReference UserReference UniquePaymentIdentifier InitialPaymentIdentifier); do
	fv=$(getField $lx $TRN)

	if [ "$lx" == "SWIFTRef" ]; then
		fv=$(echo $SWREF | tr 'a-z' 'A-Z')
	fi

	if [ "$lx" == "PseudoAckNack" ]; then
		fv=$TRN
	fi

	if [ "$fv" == "" ]; then
		fv=$TRN
	fi

	showmessage "Info: setField $lx $fv ak $step"

	step=$(setField $lx $fv "ak" $step)

done

showmessage "Info: Step = $step"

if [ $(grep % ak_$step.txt | wc -l) -gt 0 ]; then
	showmessage "Error: Something wrong the last file ak_$step.txt still have something to replace...."
	grep % ak_$step.txt
	exit
fi

cp ak_$step.txt ak_aa.txt

showmessage "Info: Removing temporary files.."
cleanUp "ak" $step

if [ "$area" == "bnk_v60_svc_qa" ]; then
	mq_tester -m SERVQM -q BNK.V60.SVC.QA.RTI1.RCV -n -f ak_aa.txt
elif [ "$area" == "mlara_bnk" ] || [ "$area" == "dev" ]; then
	mq_tester -m SERVQM -q MLARA_BNK.RTI1.RCV -n -f ak_aa.txt
else
	showmessage "Error: AREA not defined: AREA = $area"
	exit
fi

sleep 3

TRN1=$(getLastTrnFmt 2)

if [ "$TRN1" != "$TR" ] && [ $trn_provided -eq 0 ]; then
	showmessage "Error: Something wrong with your AK transaction ...."
	showmessage "Error: A new transaction is created when the AK does not match with the origina pacs.008."
	showmessage "To know what wrong print your message. Original: $TR - AK = $TRN1"
else
	showmessage "Info: AK Send with Success !"
	showmessage "Info: Print your Original transaction: $TRN"
fi
