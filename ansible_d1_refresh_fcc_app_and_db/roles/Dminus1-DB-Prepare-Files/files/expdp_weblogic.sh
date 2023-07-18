#! /bin/bash
## Step4 ##


ORACLE_SID=$1
DAY_DATE=$2
ORA_HOME=$3
Automate_DIR=$4
OWNER=$5


source ${ORA_HOME}/.bash_profile > /dev/null

export ORACLE_SID=$1
export bckuser=bckuser${ORACLE_SID}
export bckpass=bckpass${ORACLE_SID}

### Add 20230516 ###


export WEBLOG_DUMP_PATH=/backup/dump/weblogic_dumps
export WEBLOG_DUMP_LOG_PATH=/backup/dump/weblogic_log
export KEEP=10
export MTIME=+${KEEP}

##export DAY_DATE=`date +%Y%m%d`
/bin/mkdir -p /Automate/D-1/Scripts/SQL/${DAY_DATE}
/bin/mkdir -p /Automate/D-1/logs/${ORACLE_SID}/${DAY_DATE}


#########

checkpoint=1
if [ $checkpoint -eq 1 ]
then

### Add 20230516 ###

$ORACLE_HOME/bin/sqlplus -s "/ as sysdba" <<-EOF
set line 500;
set pagesize 200;
set echo on;
spool /Automate/D-1/logs/${ORACLE_SID}/${DAY_DATE}/04-create_dirctory.log
create or replace directory WEBLOGIC_DUMP as '/backup/dump/weblogic_dumps';
create or replace directory WEBLOGIC_LOG as '/backup/dump/weblogic_log';
spool off;
exit;
EOF

#########


###########################
##### Start export #######
# select directory_path from dba_directories where directory_name = 'BKUP_DIR';
# /oradata/dump

### Update 20230516 ###

  echo "Backup FCC Parameter table"
  expdp ${!bckuser}/${!bckpass} directory=WEBLOGIC_DUMP REUSE_DUMPFILES=Y dumpfile=WEBLOGIC_DUMP:FCC_USER_PARAM_${ORACLE_SID}_${DAY_DATE}.dmp logfile=WEBLOGIC_LOG:FCC_USER_PARAM_${ORACLE_SID}_${DAY_DATE}.log parfile=${Automate_DIR}/par/exp_fcc_param_${ORACLE_SID}.par
  echo "Backup RCU Data"
  expdp ${!bckuser}/${!bckpass} directory=WEBLOGIC_DUMP REUSE_DUMPFILES=Y dumpfile=WEBLOGIC_DUMP:FCC_WEBLOGIC_${ORACLE_SID}_${DAY_DATE}.dmp logfile=WEBLOGIC_LOG:FCC_WEBLOGIC_${ORACLE_SID}_${DAY_DATE}.log parfile=${Automate_DIR}/par/exp_fcc_weblogic_param_${ORACLE_SID}.par


cp /backup/dump/weblogic_log/FCC_USER_PARAM_${ORACLE_SID}_${DAY_DATE}.log /Automate/D-1/logs/${ORACLE_SID}/${DAY_DATE}/04-expdp_FCC_USER_PARAM_${ORACLE_SID}_${DAY_DATE}.log

cp /backup/dump/weblogic_log/FCC_WEBLOGIC_${ORACLE_SID}_${DAY_DATE}.log /Automate/D-1/logs/${ORACLE_SID}/${DAY_DATE}/04-expdp_FFCC_WEBLOGIC_${ORACLE_SID}_${DAY_DATE}.log

#------------------------------------------------------------
# Delete dump file/log more than 20 days
#------------------------------------------------------------
#------------- ALERT LOG ---------------
# cd $WEBLOG_DUMP_PATH
# find . -name "fcc_weblog01*.dmp" -mtime $MTIME -exec rm -rf {} \;
#
# cd $WEBLOG_DUMP_LOG_PATH
# find . -name "fcc_weblog01*.log" -mtime $MTIME -exec rm -rf {} \;

echo "Step 04 Export Dump for FCC and Weblogic ${ORACLE_SID} ${DAY_DATE} done--> /backup/dump/weblogic_dumps" | tee -a  /tmp/trace_refresh_${ORACLE_SID}_${DAY_DATE}.log

fi
