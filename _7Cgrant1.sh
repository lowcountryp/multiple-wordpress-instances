#!/bin/bash -x

function doGrant () {
#set -o verbose 
#echo on 

BTICK="'"
QUOTE='"'
CMD=';'
EXPECTED_ARGS=3
E_BADARGS=65
E_EXISTS=13
MYSQL='mysql'
# SID is system ID, the instance ID for the install
SID="$1"
relChar="_"
thisWho=$(whoami)
ipaddr="-.-.-.-"

if [ $# -ne $EXPECTED_ARGS ]
then
echo "Usage: REQUIRES 3 PARMS $0 dbname dbuser dbpass"
exit $E_BADARGS
fi

thisPW=${BTICK}$3${BTICK}

Q2="grant all on "$1".* TO "$2"@localhost identified by "$thisPW";"
Q3="FLUSH PRIVILEGES;"

#For inserting the transaction tracking record...
QInsertTranDB="mst7care"
QInsertTranTbl="7cSetupTrans"

echo "GRANT USER PRIVILEGES==>"$2 
$MYSQL -uroot -p#password -e "$Q2"
$MYSQL -uroot -p#password -e "$Q3"

#Insert a transaction record - something happened, we need to know what and when...
sidAdminEmail="GRANTAUTH"
NOW=$(date +"%Y%m%d%H%M%S")
sidQ="AU"
INSERT_TRANS="use ${QInsertTranDB};insert into ${QInsertTranTbl} (SID, sidUser, upass, sidQ, sidAdmEmail, sidTimeStamp, sidSetupString, setupUser, setupIPAddr) VALUES(${BTICK}$1${BTICK},${BTICK}$2${BTICK},${BTICK}$3${BTICK},${BTICK}$sidQ${BTICK},${BTICK}$sidAdminEmail${BTICK},${BTICK}$tStamp${BTICK},${BTICK}$NOW${BTICK},${BTICK}$thisWho${BTICK},${BTICK}$ipaddr${BTICK});"

$MYSQL -uroot -p#password -e "$INSERT_TRANS"

}
doGrant $1 $2 $3 | tee grantIt.txt
