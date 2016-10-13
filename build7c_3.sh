#!/bin/bash -x

LOGFILE=/var/log/build7c.log

function doBuild () {
set -o verbose 
#echo on 
echo "1 $1"; 
echo "2 $2"; 
echo "3 $3"; 
echo "4 $4"; 
echo "5 $5"; 

BTICK="'"
QUOTE='"'
CMD=';'
EXPECTED_ARGS=5
E_BADARGS=65
E_EXISTS=13
MYSQL='mysql'
# SID is system ID, the instance ID for the install
SID="$1"
relChar="_"
thisWho=$(whoami)
ipaddr="-.-.-.-"
echo ""
echo "==> "


if [ $# -ne $EXPECTED_ARGS ]
then
echo "Usage: REQUIRES 5 PARMS $0 dbname dbuser dbpass queuename adminEmailName"
exit $E_BADARGS
fi

echo "TESTING FOR UNIQUE INSTANCE==>$1"
RESULT1='mysql -uroot -p#password  -e '$QUOTE
RESULT1A='SHOW DATABASES LIKE '
RESULT2=${BTICK}$1${BTICK}${CMD}${QUOTE}
RESULT=$RESULT1$RESULT1A$RESULT2
NOW=$(date +"%Y%m%d%H%M%S")
#NOW=$(date +"%s")
fileExt=".txt"


# Build the title for output file that will trap whether the database/SID exists
tStamp=$SID$relChar$((RANDOM%10000000000+10000000))$NOW

outFile=/home/u7care/$tStamp$fileExt

eval $RESULT >>$outFile

#if the database is found, the output file size > 0...

resultFileSz=$( stat -c %s $outFile)

#echo "Filesize: $resultFileSz"

if [ "$resultFileSz" -gt 0 ]; then
	echo " $1:  !!THIS INSTANCE ID ALREADY EXISTS!! LEAVING..." 
	exit $E_EXISTS
else
	echo "$1: THIS INSTANCE DOES NOT EXIST...CREATING " $1  
fi

echo "BUILDING INSTANCE FILE STRUCTURE==>"$1 
#copy the directory structure, then build the database...


fromDir="/home/u7care/public_html/q9/4px"
toDir="/home/u7care/public_html/"
toCopy=$toDir$4"/"$1

cp -r $fromDir $toCopy

thisPW=${BTICK}$3${BTICK}
CRT0="drop user "$2";"
CRT1="create user "$2"@localhost identified by "$thisPW";"
GRANT1="grant select,insert,update,delete,create,drop on "$1".* to "$2"@localhost identified by "$thisPW";"
Q1="create database if not exists "$1";"
Q2="grant all on "$1".* TO "$2"@localhost identified by "$thisPW";"
Q3="FLUSH PRIVILEGES;"
Q3A="USE '$1';"
Q4="use $1;"
Q6="<<EOF"
SQL0="${CRT0}"
SQL1="${Q3}${Q1}${Q3}"
SQL2="${CRT1}${Q3}"

#For inserting the transaction tracking record...
QInsertTranDB="mst7care"
QInsertTranTbl="7cSetupTrans"


#Build the database...
echo "BUILDING THE DATABASE==>"$1 >> buildit.txt
#echo $SQL0
#echo $SQL1
#First, drop the user, if it exists...
echo "DROPPING THE USER, IF EXISTS==>"$2 
$MYSQL -uroot -p#password -e "$SQL0"
echo "CREATING THE DATABASE==>"$1 
$MYSQL -uroot -p#password -e "$SQL1"
echo "CREATING THE USER==>"$2 
$MYSQL -uroot -p#password -e "$SQL2"
echo "POPULATE THE DATABASE==>"$1 
#MYSQL -uroot -p#password $1 < /home/u7care/public_html/7CareProto_001.sql
$MYSQL -uroot -p#password $1 < /home/u7care/7care_4px.sql

echo "GRANT USER PRIVILEGES==>"$2 
$MYSQL -uroot -p#password -e "$GRANT1"

#NOW . . . configure the instance specifics in the file structure
echo "BUILDING CUSTOM INSTANCE CONFIGURATION==>"$1 

# This  is a default config template - rename it
mv /home/u7care/public_html/$4/$1/wp-config.php /home/u7care/public_html/$4/$1/xx-config.000

# This isthe shell that SED knows about handling...
cp /home/u7care/wp-config_template.txt /home/u7care/public_html/$4/$1/wp-config.php

# Make the necessary changes, based on parms passed into the provisioning process
sed -i -e "s/xdbnamex/$1/" -e "s/xdbuserx/$2/" -e "s/xdbpasswordx/$3/" -e 's/xdbhost/localhost/' /home/u7care/public_html/$4/$1/wp-config.php

# Handle redirects...The new SID directory is a copy of the template, 4px, so use sed to update the access 
# ...and some of the objects have more than one reference, so use sed the required number of times...
sed -i -e "s/4px/$1/"  /home/u7care/public_html/$4/$1/.htaccess
sed -i -e "s/4px/$1/"  /home/u7care/public_html/$4/$1/wp-login.php
sed -i -e "s|/4px|/$1|"  /home/u7care/public_html/$4/$1/wp-content/themes/p2/style.css
sed -i -e "s|/4px|/$1|"  /home/u7care/public_html/$4/$1/wp-admin/css/wp-admin.min.css
sed -i -e "s|/4px|/$1|"  /home/u7care/public_html/$4/$1/wp-admin/css/wp-admin.min.css
sed -i -e "s|/4px|/$1|"  /home/u7care/public_html/$4/$1/wp-content/themes/p2/usr_process.php
sed -i -e "s|'4px'|'$1'|"  /home/u7care/public_html/$4/$1/wp-content/themes/p2/usr_process.php
sed -i -e "s|'4px'|'$1'|"  /home/u7care/public_html/$4/$1/wp-content/themes/p2/usr_process.php

echo "FINISHED INSTANCE: "$1 
echo "==>"
echo "==>"
echo "==>"
echo "==>"
echo " "

UPDATE_HOME=${Q4}"update wp_options set option_value="${BTICK}"https://7care.net/"$4"/"$1${BTICK}"  where option_name ="${BTICK}"home"${BTICK}";"
echo $UPDATE_HOME 
$MYSQL -uroot -p#password -e "$UPDATE_HOME"

UPDATE_BLOGNAME=${Q4}"update wp_options set option_value='7 Care'  where option_name ="${BTICK}"blogname"${BTICK}";"
echo $UPDATE_BLOGNAME 
$MYSQL -uroot -p#password -e "$UPDATE_BLOGNAME"


UPDATE_BLOGDESCRIPTION=${Q4}"update wp_options set option_value='Cooperation. Peace Of Mind'  where option_name ="${BTICK}"blogdescription"${BTICK}";"
echo $UPDATE_BLOGDESCRIPTION 
$MYSQL -uroot -p#password -e "$UPDATE_BLOGDESCRIPTION"

UPDATE_SITEURL=${Q4}"update wp_options set option_value='https://7care.net/"$4"/"$1$"' where option_name ="${BTICK}"siteurl"${BTICK}";"
echo $UPDATE_SITEURL 
$MYSQL -uroot -p#password -e "$UPDATE_SITEURL"

UPDATE_SITEURL=${Q4}"update wp_options set option_value='"$5"' where option_name ="${BTICK}"admin_email"${BTICK}";"
echo $UPDATE_SITEURL 
$MYSQL -uroot -p#password -e "$UPDATE_SITEURL"

#Insert a transaction record - something happened, we need to know what and when...
INSERT_TRANS="use ${QInsertTranDB};insert into ${QInsertTranTbl} (SID, sidUser, upass, sidQ, sidAdmEmail, sidTimeStamp, sidSetupString, setupUser, setupIPAddr) VALUES(${BTICK}$1${BTICK},${BTICK}$2${BTICK},${BTICK}$3${BTICK},${BTICK}$4${BTICK},${BTICK}$5${BTICK},${BTICK}$tStamp${BTICK},${BTICK}$NOW${BTICK},${BTICK}$thisWho${BTICK},${BTICK}$ipaddr${BTICK});"

$MYSQL -uroot -p#password -e "$INSERT_TRANS"


}
doBuild $1 $2 $3 $4 $5 | tee buildit.txt
