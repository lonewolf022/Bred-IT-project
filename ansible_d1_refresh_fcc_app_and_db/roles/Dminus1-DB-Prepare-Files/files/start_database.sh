#!/bin/bash
## Step6 ##

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

### run startup & recover on D-1 side ####

$ORACLE_HOME/bin/sqlplus -s "/as sysdba" <<-EOF
spool ${Automate_DIR}/logs/${ORACLE_SID}/${DAY_DATE}/06-startup_D1_${ORACLE_SID}_${DAY_DATE}.log
startup mount;
alter database open;
spool off;
exit;

EOF


echo "Step 06 Start database ${ORACLE_SID} ${DAY_DATE} done" | tee -a  /tmp/trace_refresh_${ORACLE_SID}_${DAY_DATE}.log

fi
