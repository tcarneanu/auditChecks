#!/bin/bash

ZIP_DIR="/opt/hawkEye/checks"
BAK_DIR="/opt/hawkEye/checks/processed"
ZERO_DIR="/opt/hawkEye/checks/offlineMachines"
WORKING_DIR="/opt/hawkEye/"
OS_SOFT="/opt/hawkEye/default/osSoftware.txt"
OPS_ALLOWED="/opt/hawkEye/default/operations.txt"
HR_ALLOWED="/opt/hawkEye/default/hr.txt"
SALES_ALLOWED="opt/hawkEye/default/sales.txt"

OPS=`mysql -u root -psolaris -D hawk_eye -e "SELECT * from user where empl_type='operations'"`


for i in `find $ZIP_DIR -type f -name *.zip`
do
	# unzip checks to current location /opt/hawkEye
	unzip $i

	# removes files with size 	
	find $WORKING_DIR -size 0 -exec mv {} $ZERO_DIR \;
	
	# convert from UTF-16LE to UTF-8
	find $WORKING_DIR -maxdepth 1 -type f -name "SS*" -exec iconv -f UTF-16LE -t UTF-8 {} -o {} \;

	# filter SYS related software	
	for j in `find $WORKING_DIR -maxdepth 1 -type f -name "SS*"`
	do 
		FILENAME=`basename $j`
		grep -v -f $OS_SOFT  $WORKING_DIR$FILENAME > /tmp/$FILENAME; mv -f /tmp/$FILENAME $WORKING_DIR

	done

	# rename files 	
        for j in `find $WORKING_DIR -maxdepth 1 -type f -name "SS*"`
        do
		BASENAME=`basename $j | awk -F "-" '{print $1}'`
		mv $j $BASENAME
        done

	
	for j in `find $WORKING_DIR -maxdepth 1 -type f -name "SS*"`
	do
		BASENAME=`basename $j`	
		echo User with PC $j has the follwing type >> test.txt
		EMPL_TYPE="SELECT empl_type FROM user WHERE laptop_id like '"$BASENAME"';"
		mysql -u root -psolaris -D hawk_eye -e "$EMPL_TYPE" >> test.txt
	done		
	
	# move files to processed directory in the end
	#mv /opt/hawkEye/SS* $BAK_DIR

	# remove archive from directory checks since it has been checked
	#rm $i
done
