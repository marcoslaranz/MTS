#!/bin/bash
#### this should be included in all scripts ###############
source $AREA_ROOT_DIR/scripts/libShare.sh
shname=$(getShellName $BASH_SOURCE)
showmessage() {
	showMessage "$shname $1"
}
#### this should be included in all scripts ###############

showmessage "Running Send XSYS.003. "
showmessage "INF: This will send XSYS.003 to the last pacs.008 message sent or to a specified TRN"

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
	TR=$(lastTrn2.sh | awk -F: '{ print $2 }' | sed 's/ //g')
	TRN=$(echo $TR | sed 's/-//g' | sed 's/ //g')
fi

showmessage "Info: - - - Sending XSYS.003 to the Transaction TR = $TR - - -"

if [ -f /tmp/$TRN ]; then
	rm /tmp/$TRN
	sleep 2
fi

msgp $TR >/tmp/$TRN
sleep 2

# Check if this message has pacs.008
if [ $(grep "pacs.008" /tmp/$TRN | wc -l) -eq 0 ]; then
	showmessage "ERR: The transaction $TR does not have the pacs.008"
	exit
fi

showmessage "Inf: pass - check transaction $TR. This message has pacs.008."

# Check if this message has already received the xsys.003
if [ $(grep "Refusal Notification" /tmp/$TRN | wc -l) -gt 0 ]; then
	showmessage "ERR: The transaction $TRN alredy received xsys.003"
	exit
fi

showmessage "Inf: pass - check transaction $TR. Does not have the xsys.003 yet."

# Check if this message has already received the xsys.002
if [ $(grep "Authorisation Notification" /tmp/$TRN | wc -l) -gt 0 ]; then
	showmessage "ERR: You cannot send the xsys.003 because the transaction $TRN alredy received xsys.002"
	exit
fi

showmessage "Inf: pass - check transaction $TR. Does not have the xsys.002 yet."

# Check i fthis message has AK1
if [ $(grep "AK1" /tmp/$TRN | wc -l) -eq 0 ]; then
	showmessage "ERR: You need to send the AK first."
	exit
fi

showmessage "Inf: pass - check transaction $TR. Does have the AK1."

#### get Fields from original #####

SWREF=$(cat /tmp/$TRN | grep SWI54321- | awk '{ print $3 }' | sed 's/ //g')

dt=$(getField CreDtTm)

for lx in $(echo SenderReference UserReference SWIFTRef SnFRef OrigSnfRef UniquePaymentIdentifier InitialPaymentIdentifier MsgRef CrDate SnFRef); do
	fv=$(getField $lx $TRN)

	if [ "$lx" == "SWIFTRef" ] || [ "$lx" == "SnFRef" ]; then
		if [ "$SWREF" == "" ]; then
			echo ERROR: Was not possible find the SWIFT REF did you send the AK 1 k r
			cleanUp "sy" $step
			exit
		fi
		fv=$SWREF
	fi

	if [ "$fv" == "" ]; then
		fv=$TRN
	fi

	if [ "$lx" == "InitialPaymentIdentifier" ]; then
		fv=$(expr $TRN + 1)
	fi

	showmessage "Info: setField $lx $fv sy $step"

	step=$(setField $lx $fv "sy" $step)

done

if [ -f sy_aa_003.txt ]; then
	rm sy_aa_003.txt
fi

cp "sy_"$step".txt" sy_aa.txt

showmessage "Info: Removing temporary files.."
cleanUp "sy" $step

xmllint --format --compress sy_aa.txt >sys.tst_compress

if [ "$area" == "bnk_v60_svc_qa" ]; then
	mq_tester -m SERVQM -q BNK.V60.SVC.QA.RTI1.RCV -n -f sys.tst_compress
elif [ "$area" == "mlara_bnk" ]; then
	mq_tester -m SERVQM -q MLARA_BNK.RTI1.RCV -n -f sys.tst_compress
else
	showmessage "Info: AREA not defined: AREA = $area"
	exit
fi

TRN=$(lastTrn2.sh)

showmessage "Info: xsys TRN = $TRN "
