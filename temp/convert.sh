#!/bin/bash

export format=o7

for lx in $(cat tables.txt); do
	echo Converting table: $lx

	rgw_cvt -$format -input RGW_BY_LOGS_DMP_OUTPUT -output $lx.LOAD -spec $(bld_path_ls SBJ_SQL_PATH/rgw_message_rec.rgw_${format}_cvt)

	sleep 2

done
