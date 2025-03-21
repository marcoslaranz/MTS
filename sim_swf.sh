#!/bin/bash

cd $AREA_ROOT_DIR/config

#Start the lines to receive ACK/NAC
linecmd -bank bnk -line swf1_rcv -up
sleep 3
linecmd -bank bnk -line swf1_snd -up
sleep 3
linecmd -bank bnk -line swf2_rcv -up
sleep 3
linecmd -bank bnk -line swf2_snd -up

c=$(ent p | grep isi2swf_sim | wc -l)
if [ $c -gt 0 ]; then
	echo $(date): Simulator already started !!!
	exit
fi

isi2swf_sim -f swf.sim >$AREA_ROOT_DIR/logs/swf.sim.log 2>&1 &
isi2swf_sim -f swf2.sim >$AREA_ROOT_DIR/logs/swf2.sim.log 2>&1 &
