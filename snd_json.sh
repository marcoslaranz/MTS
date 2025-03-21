#!/bin/bash

#This is: nrc3lwestpac01vm = 10.13.31.66

if [ "$1" == "" ]; then
	echo Please provide the JSON file name.
	exit
fi

#fname=API1_SOA_1_Request.json

fname=$1

#cat $fname | json_pp -json_opt pretty,canonical > /tmp/$fname

mv /tmp/$fname $fname

#curl --data @$fname http://10.13.31.66:9306 > Json_Response.txt

#hostname : nrc3dvaipmupf02
curl --data @$fname http://10.13.31.2:9306 >Json_Response.txt

cat Json_Response.txt | json_pp -json_opt pretty,canonical >Json_Response_Beautiful.txt

cat Json_Response_Beautiful.txt
