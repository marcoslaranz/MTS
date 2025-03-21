#!/bin/bash

cd /home/mtsadmin/share/Public/RGW_6.0/xx

adirs=()

for lx in $(sshpass -p 'Bbeme012' ssh brandinm@10.5.26.201 'ls -ltr /usr/local/intranet/areas/bnk_v60_svc_qa/output* | grep ex' | awk '{print $9 }'); do
	echo Adding: $lx
	adirs+=("$lx")
done

for ((i = 0; i < ${#adirs[@]}; i++)); do
	d=${adirs[$i]}
	bk=$(echo $d | sed 's/ex/bk/')

	echo $(date): Copying files from $d
	sshpass -p 'Bbeme012' scp brandinm@10.5.26.201:/usr/local/intranet/areas/bnk_v60_svc_qa/output/"$d"/*.LOAD dat
	echo $(date): Copy completed.

	cd dat

	echo $(date): Deleting empty files
	for lx in $(ls -ltr | awk '{gsub(/ /,"",$5); if($5==0) print $9 }'); do
		echo $(date): Deleting file $lx
		echo "rm "$lx
	done

	cd ..

	echo $(date): Backuping copied directory $lx to $bk in the remote server.
	sshpass -p 'Bbeme012' ssh brandinm@10.5.26.201 'mv /usr/local/intranet/areas/bnk_v60_svc_qa/output/$d /usr/local/intranet/areas/bnk_v60_svc_qa/output/$bk'

	echo $(date): Loading files from last copy $lx
	./load.sh

	sleep 2

done
