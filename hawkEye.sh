#!/bin/bash

ZIP_DIR="/opt/hawkEye/checks"
BAK_DIR="/opt/hawkEye/checks/processed"

unzip_check() {
	unzip $1
}

move_to_processed() {
	mv $1 $2
}


for i in `find $ZIP_DIR -type f -name *.zip`
do
	# unzip checks to current location /opt/hawkEye
	unzip $i

	find /opt/hawkEye -size 0
	# move files to processed directory in the end
	#mv /opt/hawkEye/SS* $BAK_DIR

	# remove archive from directory checks since it has been checked
	#rm $i
done
