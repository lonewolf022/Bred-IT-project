#!/bin/bash
## Step8 ##


ORACLE_SID=$1
DAY_DATE=$2
ORA_HOME=$3
Automate_DIR=$4

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
if [ $checkpoint -eq 1 ]; then

### Add 20230516 ###

$ORACLE_HOME/bin/sqlplus -s "/as sysdba" <<-EOF
set heading off feedback off
set line 500
set pagesize 200
spool /Automate/D-1/logs/${ORACLE_SID}/${DAY_DATE}/08-create_directory.log
create or replace directory WEBLOGIC_DUMP as '/backup/dump/weblogic_dumps';
create or replace directory WEBLOGIC_LOG as '/backup/dump/weblogic_log';
spool off;
exit;
EOF

### ### ###

$ORACLE_HOME/bin/sqlplus -s "/as sysdba" <<-EOF
set long 20000 longchunksize 20000 pagesize 0 linesize 1000 feedback off verify off trimspool on;
col machine format a30;
col module format a20;
col program format a25;
col username format a15;
SET HEADING OFF feedback OFF
spool ${Automate_DIR}/Scripts/SQL/${ORACLE_SID}/${DAY_DATE}/Step_DropWebLogicUser_${ORACLE_SID}_${DAY_DATE}.sql;
select  'alter system kill session ''' || sid || ',' || serial# || ''' immediate;' from v\$session where REGEXP_LIKE (USERNAME, '*_IAU*|*_WLS|*_OPSS|*_STB');
SELECT 'alter user ' || USERNAME || '  account lock;' FROM all_users where REGEXP_LIKE (USERNAME, '*_IAU*|*_WLS|*_OPSS|*_STB');
SELECT 'drop user ' || USERNAME || '  cascade;' FROM all_users where REGEXP_LIKE (USERNAME, '*_IAU*|*_WLS|*_OPSS|*_STB');
spool off;

SPOOL ON
SET DEFINE OFF
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON
SET ERRORLOGGING ON
spool ${Automate_DIR}/logs/${ORACLE_SID}/${DAY_DATE}/08-Step_DropWebLogicUser_${ORACLE_SID}_${DAY_DATE}.log
@${Automate_DIR}/Scripts/SQL/${ORACLE_SID}/${DAY_DATE}/Step_DropWebLogicUser_${ORACLE_SID}_${DAY_DATE}.sql
spool off;

spool ${Automate_DIR}/Scripts/SQL/${ORACLE_SID}/${DAY_DATE}/Step_UnWebLogicUser_${ORACLE_SID}_${DAY_DATE}.sql;
SELECT 'alter user ' || USERNAME || '  account unlock;' FROM all_users where REGEXP_LIKE (USERNAME, '*_IAU*|*_WLS|*_OPSS|*_STB');
spool off;
exit;
EOF

### Import Application & weblogic schema


#impdp ${!bckuser}/${!bckpass} dumpfile=WEBLOGIC_DUMP:FCC_USER_PARAM_${ORACLE_SID}_${DAY_DATE}.dmp logfile=WEBLOGIC_LOG:IMP_FCC_USER_PARAM_${ORACLE_SID}_${DAY_DATE}.log remap_schema=${OWNER}:${OWNER} TRANSFORM=SEGMENT_ATTRIBUTES:N:table transform=OID:n table_exists_action=truncate content=data_only

impdp ${!bckuser}/${!bckpass} dumpfile=WEBLOGIC_DUMP:FCC_WEBLOGIC_${ORACLE_SID}_${DAY_DATE}.dmp logfile=WEBLOGIC_LOG:impdp_weblog01_${ORACLE_SID}_${DAY_DATE}.log parfile=${Automate_DIR}/par/imp_weblogic_data_${ORACLE_SID}.par

cp /backup/dump/weblogic_log/impdp_weblog01_${ORACLE_SID}_${DAY_DATE}.log ${Automate_DIR}/logs/${ORACLE_SID}/${DAY_DATE}/08-Impdp_weblogic_${ORACLE_SID}_${DAY_DATE}.log


$ORACLE_HOME/bin/sqlplus -s "/as sysdba" <<-EOF
set heading off feedback off
set line 500
set pagesize 200
spool ${Automate_DIR}/logs/${ORACLE_SID}/${DAY_DATE}/08-Step_UnWebLogicUser_${ORACLE_SID}${DAY_DATE}.log
@${Automate_DIR}/Scripts/SQL/${ORACLE_SID}/${DAY_DATE}/Step_UnWebLogicUser_${ORACLE_SID}_${DAY_DATE}.sql
spool off;
exit;
EOF

echo "Step 08 Import dump Weblogic data ${ORACLE_SID} ${DAY_DATE}" | tee -a  /tmp/trace_refresh_${ORACLE_SID}_${DAY_DATE}.log

fi
