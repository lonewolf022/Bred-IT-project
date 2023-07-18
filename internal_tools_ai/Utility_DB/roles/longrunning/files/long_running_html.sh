#!/bin/bash
. /home/oracle/.bash_profile > /dev/null
# ENV=$2
WORKDIR="/home/oracle/Scripts/bin"
TODAY_DATE=$2

export ORACLE_SID=$1

cd $WORKDIR
(
${ORACLE_HOME}/bin/sqlplus -s '/  as sysdba ' << EOF
spool /spools/html_${ORACLE_SID}_${TODAY_DATE}.spl
set verify off
set heading off
set echo on
set pages 900
set line 900
set lines 256
set trimout on
set tab off
--COLUMN ID FORMAT 9999
COLUMN SESSION_DB FORMAT A10
COLUMN USERNAME FORMAT A10
COLUMN  OSUSER-MACHINE FORMAT A30
COLUMN  PROGRAM FORMAT A40
COLUMN  EVENT FORMAT A40
set colsep "|"
SELECT
--         ss.inst_id ID ,
           ss.SID  ||','||ss.Serial# SESSION_DB,
--         DECODE (ss.BLOCKING_SESSION,
--                 ss.BLOCKING_INSTANCE || ')' || ss.BLOCKING_SESSION, '')
--            "WAIT_INST_SID",
         ss.USERNAME,
         ss.OSUSER || '@' || ss.MACHINE "OSUSER-MACHINE",
--         ss.PROGRAM,
--         ss.event,
         (SYSDATE - (ss.LAST_CALL_ET / 86400)) "START_EXEC_TIME",
            ROUND (
               TO_NUMBER (SYSDATE - (SYSDATE - (ss.LAST_CALL_ET / 86400))) * 24,2)"Hour",
             ROUND (
                 TO_NUMBER (SYSDATE - (SYSDATE - (ss.LAST_CALL_ET / 86400)))* 24* 60,2)
            "Min",
         ss.status
    FROM gv\$session ss
   WHERE     ss.status = 'ACTIVE'
         AND ss.username NOT IN ('SYS', 'SYSTEM')
         AND ss.username IS NOT NULL and ss.OSUSER not in ('oracle')
         AND ss.LAST_CALL_ET / 60 > 30
ORDER BY 7;
spool off
exit
EOF
)
