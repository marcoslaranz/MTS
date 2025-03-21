#!/bin/bash
cd $AREA_ROOT_DIR
for lx in $(l | grep bak_log | awk '{ print $9 }'); do
	echo Deleting backup : $lx
	rm -rf $lx
done
