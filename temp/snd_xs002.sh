#!/bin/bash
#
#
# **M. Lara,**
#
# Send the xsys.002 to the pacs.008 message.
#
# Here's what to check if the AK doesn't match:
#
# 1. The AK is sent to the RTI1_RCV line. Verify if this line is up and running.
# 2. Check the RTI1_SND line. Issues with the sequence number can prevent the line from going up.
# Review the logs for this line, adjust the sequence number if necessary,
# and then attempt to bring the line up.
# 3. Pending queues can obstruct message processing. Clear all messages from the pending queues.
# 4. Be sure you have sent the AK before, if not this will fail.
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

showmessage "Running Send XSYS.002. "

dt=$(date +"%Y-%m-%dT%TZ")

step=0

area=$(area | grep area | cut -c 18- | sed 's/"//g' | sed 's/ //g' | sed 's/.//g')
if [ "$area" == "" ]; then
	showmessage "Error: AREA was not found..."
	exit
fi

echo AREA: $area

if [ "$1" != "" ]; then
	if [ $(echo $1 | grep "-" | wc -l) -gt 0 ]; then
		TR=$1
		TRN=$(echo $1 | sed 's/-//g' | sed 's/ //g')
	else
		TRN=$1
		TR=$(echo $1 | cut -c 1-8)"-"$(echo $1 | cut -c 9-)
	fi
else
	TR008=$(getLastTrnFmt 2)
	TRN008=$(getLastTrnFmt 3)
fi

showmessage "Info: - - - Sending XSYS.002 to the Transaction TR = $TR008 - - -"

if [ -f /tmp/$TRN008 ]; then
	rm /tmp/$TRN008
	sleep 2
fi

msgp $TR008 >/tmp/$TRN008

# Check if MessageIdentifier is of this message is pacs.008
msgi=$(grep MessageIdentifier /tmp/$TRN008 | sed 's/ //g' | awk -F >'{ print $2 }' | awk -F <'{print $1 }' | cut -c 1-8)

showmessage "Info: MessageIdentifier $msgi"

if [ "$msgi" != "pacs.008" ]; then
	showmessage "ERR: The transaction $TR008 does not have the pacs.008 $msgi"
	exit
fi

showmessage "Inf: pass - check transaction $TR008. This message has pacs.008."

# Check if this message has already received the xsys.003
if [ $(grep "Refusal Notification" /tmp/$TRN008 | wc -l) -gt 0 ]; then
	showmessage "ERR: The transaction $TR008 alredy received xsys.003. You cannot send the xsys.002"
	exit
fi

showmessage "Inf: pass - check transaction $TR008. Does not have the xsys.003 yet."

# Check if this message has already received the xsys.002
if [ $(grep "Authorisation Notification" /tmp/$TRN008 | wc -l) -gt 0 ]; then
	showmessage "ERR: This transaction $TRN alredy received xsys.002"
	exit
fi

showmessage "Inf: pass - check transaction $TR008. Does not have the xsys.002 yet."

# Check i fthis message has AK1
if [ $(grep "AK1" /tmp/$TRN008 | wc -l) -eq 0 ]; then
	showmessage "ERR: You need to send the AK first."
	exit
fi

showmessage "Inf: pass - check transaction $TR008. Does have the AK1."

#### get Fields from original #####

SWREF=$(cat /tmp/$TRN008 | grep SWI54321- | awk '{ print $3 }' | sed 's/ //g')

cp sy_0_002.txt sy_0.txt

dt=$(getField CreDtTm)

for lx in $(echo SenderReference UserReference SWIFTRef SnFRef OrigSnfRef UniquePaymentIdentifier InitialPaymentIdentifier MsgRef CrDate SnFRef); do
	fv=$(getField $lx $TRN008)

	if [ "$lx" == "SWIFTRef" ] || [ "$lx" == "SnFRef" ]; then
		if [ "$SWREF" == "" ]; then
			echo ERROR: Was not possible find the SWIFT REF did you send the AK 1 k r
			cleanUp "sy" $step
			exit
		fi
		fv=$SWREF
	fi

	if [ "$fv" == "" ]; then
		fv=$TRN008
	fi

	if [ "$lx" == "InitialPaymentIdentifier" ]; then
		fv=$(expr $TRN008 + 1)
	#fv=$fv"`date +"%h%m%s"`"
	fi

	showmessage "Info: setField $lx $fv sy $step"

	step=$(setField $lx $fv "sy" $step)

done

f="sy_"$step".txt"

cp $f sy_aa.txt
if [ $? -ne 0 ]; then
	showmessage "Error: file not found .file: $f"
	exit
fi

showmessage "Info: Removing temporary files.."
cleanUp "sy" $step

xmllint --format --compress sy_aa.txt >sys.tst_compress

if [ "$area" == "bnk_v60_svc_qa" ]; then
	mq_tester -m SERVQM -q BNK.V60.SVC.QA.RTI1.RCV -n -f sys.tst_compress
elif [ "$area" == "mlara_bnk" ] || [ "$area" == "dev" ]; then
	mq_tester -m SERVQM -q MLARA_BNK.RTI1.RCV -n -f sys.tst_compress
else
	showmessage "Info: AREA not defined: AREA = $area"
	exit
fi

TRN002=$(getLastTrnFmt 2)

# The TRN008 needs to be update to show Y-Copy in the History
msgp $TR008 >/tmp/$TRN008

sleep 2

showmessage "Info: xsys.002 TRN = $TRN002 "
showmessage "Info: pacs.008 TRN = $TR008 "

#
# Check if your message received the xsys.002
#
if [ $(grep "Y-Copy Authorisation" /tmp/$TRN008 | wc -l) -eq 0 ]; then
	showmessage "ERR: The xsys.002 sent $TRN002 did not updated your original transaction $TR008"
else
	showmessage "INF: The xsys.002 sent $TRN002 Successfuly updated your original transaction $TR008"

fi
