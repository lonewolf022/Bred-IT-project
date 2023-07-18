#!/bin/bash

## Step1 ##

ORACLE_SID=$1
DAY_DATE=$2
ORA_HOME=$3
Automate_DIR=$4

source ${ORA_HOME}/.bash_profile > /dev/null

##export DAY_DATE=`date +%Y%m%d`
/bin/mkdir -p /Automate/D-1/logs/${ORACLE_SID}/${DAY_DATE}

checkpoint=1
if [ $checkpoint -eq 1 ]
then
export ORACLE_SID=$1

### run freeze on Production side ####

$ORACLE_HOME/bin/sqlplus -s "/as sysdba" <<-EOF
spool /Automate/D-1/logs/${ORACLE_SID}/${DAY_DATE}/01-Freeze_DB_${ORACLE_SID}_${DAY_DATE}.log
ALTER SYSTEM SWITCH LOGFILE;
ALTER SYSTEM SWITCH LOGFILE;
ALTER SYSTEM SWITCH LOGFILE;
ALTER SYSTEM SWITCH LOGFILE;
ALTER SYSTEM ARCHIVE LOG CURRENT; 
ALTER DATABASE BEGIN BACKUP;

spool off;
exit;

EOF

echo "Step 01 Freeze_DB_${ORACLE_SID} ${DAY_DATE} done" | tee -a  /tmp/trace_refresh_${ORACLE_SID}_${DAY_DATE}.log

fi
