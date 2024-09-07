#!/bin/bash
# Image header detector by ZH-XiJun

# Stop script when meet error
set -e

# Remove DHTB header with dd
function header(){
	echo "Detected DHTB header, remove it first..."
	dd if="${input}" of=tmp bs=512 skip=1
	rm "${input}"
	mv tmp "${input}"
	echo "Removed successfully"
	return 0
}

input=$1

# Detect whether the file is exist
if [ ! -f "${input}" ] ; then
	echo "File not found, error!"
	exit 127
fi

# Read the first 8 bytes of the file
result=$(od -N8 -t x1 "${input}"|head -1|sed -e 's/0000000//g' -e 's/ //g')

# 414e44524f494421 is "ANDROID!" in hex
if [ ! ${result} = "414e44524f494421" ] ; then
	echo "Invalid file header detected, need further operation..."
	# 44485442 is "DHTB" in hex
	if [ ${result} = "4448544201000000" ] ; then
		header
		exit 0
	# Special situation which is beyond the scope of the tool's work
	else
		echo "Invalid file header! Pls make sure the file you provided is a valid android boot image"
		exit 1
	fi
# Exit the script when the image header seems normal.
else
	echo "It seemed like a valid android boot image, continue..."
	exit 0
fi

