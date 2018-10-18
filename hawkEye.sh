#!/bin/bash

ZIP_DIR="/opt/hawkEye/checks"
BAK_DIR="/opt/hawkEye/checks/processed"
ZERO_DIR="/opt/hawkEye/checks/offlineMachines"
WORKING_DIR="/opt/hawkEye/"
OS_SOFT="/opt/hawkEye/default/osSoftware.txt"
OPS_ALLOWED="/opt/hawkEye/default/operations.txt"
HR_ALLOWED="/opt/hawkEye/default/hr.txt"
SALES_ALLOWED="/opt/hawkEye/default/sales.txt"

for i in `find $ZIP_DIR -type f -name *.zip`
do
	# unzip checks to current location /opt/hawkEye
	unzip $i &> /dev/null
	
	ARCHIVE_NAME=`basename $i | awk -F "." '{print $1}'`
	echo "----------------------------------------------------------------------------------------" >> mail.txt
	echo Checked on $ARCHIVE_NAME >> mail.txt
	echo "----------------------------------------------------------------------------------------" >> mail.txt

	# removes files with size 	
	find $WORKING_DIR -size 0 -exec mv -f {} $ZERO_DIR \;
	
	# convert from UTF-16LE to UTF-8
	find $WORKING_DIR -maxdepth 1 -type f -name "SS*" -exec dos2unix -ascii {} \; 

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
		mv -f $j $BASENAME
        done

	TOTAL_COUNT="update user set totalChecks=totalChecks+1;"
	mysql -u root -psolaris -D hawk_eye -e "$TOTAL_COUNT"

	# comparison to allowed software files for each type of employee	
	for j in `find $WORKING_DIR -maxdepth 1 -type f -name "SS*"`
	do
		BASENAME=`basename $j`	
		EMPL_TYPE="SELECT empl_type FROM user WHERE laptop_id like '"$BASENAME"';"
		SQL=`mysql -u root -psolaris -D hawk_eye -s -e "$EMPL_TYPE"`
		EMPL_NAME="SELECT name FROM user WHERE laptop_id like '"$BASENAME"';"
	        SQL_NAME=`mysql -u root -psolaris -D hawk_eye -s -e "$EMPL_NAME"`

		CHECK_COUNT="update user set checkCount=checkCount+1 where laptop_id like '"$BASENAME"';"
		mysql -u root -psolaris -D hawk_eye -s -e "$CHECK_COUNT"		

		if [[ $SQL == "operations" ]]
		then
			echo "$SQL_NAME is using $BASENAME" >> mail.txt
			echo "The following programes are installed outside of allowed software list" >> mail.txt
			grep -v -f $OPS_ALLOWED $j >> mail.txt
			echo "----------------------------------------------------------------------------------------" >> mail.txt

		elif [[ $SQL == "hr" ]] 
		then

			echo "$SQL_NAME is using $BASENAME" >> mail.txt
                        echo "The following programes are installed outside of allowed software list" >> mail.txt
                        grep -v -f $HR_ALLOWED $j >> mail.txt
			echo "----------------------------------------------------------------------------------------" >> mail.txt

		elif [[ $SQL == "sales" ]] 
		then 
		
			echo "$SQL_NAME is using $BASENAME" >> mail.txt
                        echo "The following programes are installed outside of allowed software list" >> mail.txt
                        grep -v -f $SALES_ALLOWED $j >> mail.txt
			echo "----------------------------------------------------------------------------------------" >> mail.txt

		elif [[ $SQL == "mgmt" ]]
		then 
			echo "$SQL_NAME is using $BASENAME" >> mail.txt
			echo "The following programes installed " >> mail.txt
			cat $j >> mail.txt
			echo "----------------------------------------------------------------------------------------" >> mail.txt	
		elif [[ $SQL == "anevia" ]]
		then
			echo "$SQL_NAME is using $BASENAME. Employee is part of team Anevia." >> mail.txt
			cat $j >> mail.txt
			echo "----------------------------------------------------------------------------------------" >> mail.txt
		else
			echo $BASENAME is not in DB >> mail.txt
		fi
	done		
	
	# move files to processed directory in the end
	zip `date +%F` SS*
	rm -f SS*
	mv *.zip $BAK_DIR
	# remove archive from directory checks since it has been checked
	#rm $i
done
