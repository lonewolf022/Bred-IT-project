#!/bin/bash



. /home/oracle/.bash_profile

# ENV=$2
WORKDIR="/home/oracle/Scripts/bin"
TODAY_DATE=$2

export ORACLE_SID=$1

cd $WORKDIR

${ORACLE_HOME}/bin/sqlplus -s '/  as sysdba ' << EOF
set verify off
set echo on
set pages 900
set line 900
COLUMN SESSION_DB FORMAT A10
COLUMN WAIT_INST_SID FORMAT A15
COLUMN USERNAME FORMAT A10
COLUMN  OSUSER-MACHINE FORMAT A60
COLUMN  PROGRAM FORMAT A60
COLUMN  EVENT FORMAT A30
spool /spools/longrunning_${ORACLE_SID}_${TODAY_DATE}.spl

SELECT  ss.inst_id,ss.SID||','||ss.Serial#,
         DECODE (ss.BLOCKING_SESSION,
                 ss.BLOCKING_INSTANCE || ')' || ss.BLOCKING_SESSION, '')
            "WAIT INST)SID",
         ss.USERNAME,
         ss.OSUSER || '@' || ss.MACHINE "OSUSER-MACHINE",
         ss.PROGRAM,
         ss.event,
         (SYSDATE - (ss.LAST_CALL_ET / 86400)) "START_EXEC_TIME",
            ROUND (
                 TO_NUMBER (SYSDATE - (SYSDATE - (ss.LAST_CALL_ET / 86400)))
               * 24
               * 60,
               2)
         || ' Mins'
            "Elapsed Time(Minutes)",
            ROUND (
               TO_NUMBER (SYSDATE - (SYSDATE - (ss.LAST_CALL_ET / 86400))) * 24,
               2)
         || ' Hours'
            "Elapsed Time(Hour)",
         ss.status,
         ss.SQL_ID,
         (SELECT SQL_TEXT
            FROM v\$sqlarea sa
           WHERE sa.address = ss.sql_address)
            "SQL_TEXT"
    FROM gv\$session ss
   WHERE     ss.status = 'ACTIVE'
         AND ss.username NOT IN ('SYS', 'SYSTEM')
         AND ss.username IS NOT NULL and ss.OSUSER not in ('oracle')
         AND ss.LAST_CALL_ET / 60 > 30
ORDER BY 7;
spool off
exit
EOF
