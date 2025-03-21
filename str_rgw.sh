#!/bin/bash

p=$(ent p | grep rgw | wc -l | awk '{ print $1 }')

if [ $p -ne 0 ]; then
	ekill $p
fi

sleep 5

srgw_export BNK/SRGW_01 -dstText &
#srgw_export -trace BNK/SRGW_01 &
#
linecmd -bank bnk -line srgw_01 -up
