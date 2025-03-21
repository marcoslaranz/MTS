#!/bin/bash

if [ "$1" == "" ]; then
	echo Please, provide a file name xml.
	exit
fi

xmllint --format $f
