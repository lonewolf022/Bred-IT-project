#!/bin/bash
## Step7 ##

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
/bin/mkdir -p /Automate/D-1/logs/${ORACLE_SID}/${DAY_DATE}


checkpoint=1
if [ $checkpoint -eq 1 ]
then

### Add 20230516 ###

$ORACLE_HOME/bin/sqlplus -s "/as sysdba" <<-EOF
set heading off feedback off
set line 500
set pagesize 200
spool /Automate/D-1/logs/${ORACLE_SID}/${DAY_DATE}/07-create_directory.log
create or replace directory WEBLOGIC_DUMP as '/backup/dump/weblogic_dumps';
create or replace directory WEBLOGIC_LOG as '/backup/dump/weblogic_log';
spool off;
exit;
EOF

#########

$ORACLE_HOME/bin/sqlplus -s "/as sysdba" <<-EOF
SPOOL ON
SET DEFINE OFF
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON
SET ERRORLOGGING ON
spool ${Automate_DIR}/logs/${ORACLE_SID}/${DAY_DATE}/07-import_alluser_n_cleansing_logs_${ORACLE_SID}.log
prompt loading "Profile User"
prompt loading "Import User"
@${Automate_DIR}/Scripts/SQL/${ORACLE_SID}/${DAY_DATE}/ExportAllUser_${ORACLE_SID}_${DAY_DATE}.sql
prompt loading "Clean up data FCC Log"
truncate table $OWNER.smtb_sms_log;
truncate table $OWNER.smtt_sms_log;
truncate table $OWNER.CSTB_AUDIT_LOG;
truncate table $OWNER.STTB_RECORD_LOG;
truncate table $OWNER.WL_LLR;

spool off;
exit;
EOF

## import  application data
impdp ${!bckuser}/${!bckpass} directory=WEBLOGIC_DUMP dumpfile=WEBLOGIC_DUMP:FCC_USER_PARAM_${ORACLE_SID}_${DAY_DATE}.dmp logfile=WEBLOGIC_LOG:Impdp_FCC_USER_PARAM_${ORACLE_SID}_${DAY_DATE}.log remap_schema=${OWNER}:${OWNER} TRANSFORM=SEGMENT_ATTRIBUTES:N:table transform=OID:n table_exists_action=truncate content=data_only

cp /backup/dump/weblogic_log/Impdp_FCC_USER_PARAM_${ORACLE_SID}_${DAY_DATE}.log /Automate/D-1/logs/${ORACLE_SID}/${DAY_DATE}/07-Impdp_FCC_USER_PARAM_${ORACLE_SID}_${DAY_DATE}.log

echo "Step 07 Run script import user and FCC data ${ORACLE_SID} ${DAY_DATE} done" | tee -a  /tmp/trace_refresh_${ORACLE_SID}_${DAY_DATE}.log

fi
