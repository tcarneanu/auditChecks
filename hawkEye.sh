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
	
	find /opt/hawkEye -size 0 -exec rm {} \;

	find /opt/hawkEye -maxdepth 1 -type f -name "SS*" -exec iconv -f UTF-16LE -t UTF-8 {} -o {} \;
	
	#for j in `find /opt/hawkEye -maxdepth 1 -type f -name "SS*"`
	#do
	#	iconv -f UTF-16LE -t UTF-8 $j -o $j
	#done
	# move files to processed directory in the end
	#mv /opt/hawkEye/SS* $BAK_DIR

	# remove archive from directory checks since it has been checked
	#rm $i
done
