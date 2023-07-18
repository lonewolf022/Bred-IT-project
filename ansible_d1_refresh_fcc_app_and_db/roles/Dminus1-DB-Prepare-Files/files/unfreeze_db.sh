#!/bin/bash

## Step2 ##

ORACLE_SID=$1
DAY_DATE=$2
ORA_HOME=$3

##export DAY_DATE=`date +%Y%m%d`
export Automate_DIR=/Automate/D-1

/bin/mkdir -p /Automate/D-1/logs/${ORACLE_SID}/${DAY_DATE}


source ${ORA_HOME}/.bash_profile > /dev/null

checkpoint=1
if [ $checkpoint -eq 1 ]
then
export ORACLE_SID=$1

### run unfreeze on Production side ####

$ORACLE_HOME/bin/sqlplus -s "/ as sysdba" <<-EOF
spool /Automate/D-1/logs/${ORACLE_SID}/${DAY_DATE}/02-UnFreeze_DB_${ORACLE_SID}_${DAY_DATE}.log
alter database end backup;
spool off;
exit;

EOF

echo "Step 02 unFreeze_DB_${ORACLE_SID} ${DAY_DATE} done" | tee -a  /tmp/trace_refresh_${ORACLE_SID}_${DAY_DATE}.log

fi
