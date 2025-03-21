#!/bin/bash
#### this should be included in all scripts ###############
source $AREA_ROOT_DIR/scripts/libShare.sh
shname=$(getShellName $BASH_SOURCE)
showmessage() {
	showMessage "$shname $1"
}
#### this should be included in all scripts ###############

showmessage "Running database backup .."

cd $AREA_ROOT_DIR

dtb=$(date +"%d-%m-%d_%H_%M_%S")
bkd="bkdb_"$dtb
ckd="conf_"$dtb

q=$(ent status | wc -l)
if [ $? -ne 0 ]; then
	showmessage "Error: MTS is not detected. Did you setup the area command?"
	exit
fi

q=$(ent status | head -1 | grep UP | wc -l)
if [ $q -ne 0 ]; then
	showmessage "MTS is up and running. Shutdown MTS before run the backup.."
	read -p "Would you like to shutdown MTS now.. Y or N ?" X
	if [ "$X" == "Y" ]; then
		ent shutdown -g
		sleep 10
		# Check again if MTS is not running

		q=$(ent status | head -1 | grep UP | wc -l)
		if [ $? -ne 0 ]; then
			showmessage "Error MTS still running. Run a manual shutdown -g "
			exit
		fi

		showmessage "MTS shutdown with Success !!"
	else
		exit
	fi
fi

mkdir $AREA_ROOT_DIR/$bkd

cp -p database/* $bkd
if [ $? -eq 0 ]; then
	cd $bkd
	showmessage "Running gzip into backup files.."
	gzip 03660295-h24-613784 1 1_1.txt 3_1.txt 4_1.txt API1_SOA_1_Request.json API1_SOA_1_Request.json.1 BNK_check a.xml add_tsi_route.sh ak1.tst_compress ak_0.txt ak_0.txt.1 ak_0.txt.2 ak_aa.txt all_scripts.txt all_scripts2.txt bnk bkdb.sh extract.sh
	showmessage "Copying configs!"
	cd $AREA_ROOT_DIR/$bkd
	tar -cvf $ckd".tar" $AREA_ROOT_DIR/config
	showmessage "Backup completed!"
else
	showmessage "Error: Backup DID NOT completed!"
fi
