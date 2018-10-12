#!/bin/bash

ZIP_DIR="/opt/hawkEye/checks"
BAK_DIR="/opt/hawkEye/checks/processed"
ZERO_DIR="/opt/hawkEye/checks/offlineMachines"
WORKING_DIR="/opt/hawkEye/"
OS_SOFT="/opt/hawkEye/default/osSoftware.txt"

for i in `find $ZIP_DIR -type f -name *.zip`
do
	# unzip checks to current location /opt/hawkEye
	unzip $i

	# removes files with size 	
	find $WORKING_DIR -size 0 -exec mv {} $ZERO_DIR \;
	
	# convert from UTF-16LE to UTF-8
	find $WORKING_DIR -maxdepth 1 -type f -name "SS*" -exec iconv -f UTF-16LE -t UTF-8 {} -o {} \;
	
	for j in `find $WORKING_DIR -maxdepth 1 -type f -name "SS*"`
	do 
		FILENAME=`basename $j`
		grep -v -f $OS_SOFT  $WORKING_DIR$FILENAME > /tmp/$FILENAME; mv -f /tmp/$FILENAME $WORKING_DIR

	done
	# move files to processed directory in the end
	#mv /opt/hawkEye/SS* $BAK_DIR

	# remove archive from directory checks since it has been checked
	#rm $i
done
