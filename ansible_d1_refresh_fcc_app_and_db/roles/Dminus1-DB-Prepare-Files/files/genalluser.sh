#!/bin/bash

## Step3 ##

ORACLE_SID=$1
DAY_DATE=$2
ORA_HOME=$3
Automate_DIR=$4

source ${ORA_HOME}/.bash_profile > /dev/null

##export DAY_DATE=`date +%Y%m%d`
/bin/mkdir -p /Automate/D-1/Scripts/SQL/${ORACLE_SID}/${DAY_DATE}
/bin/mkdir -p /Automate/D-1/logs/${ORACLE_SID}/${DAY_DATE}


checkpoint=1
if [ $checkpoint -eq 1 ]
   then

export ORACLE_SID=$1

$ORACLE_HOME/bin/sqlplus -s "/ as sysdba" <<-EOF
WHENEVER OSERROR EXIT 1;
WHENEVER SQLERROR EXIT 1;

begin
DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);
end;
/

set long 20000 longchunksize 20000 pagesize 0 linesize 1000 feedback off verify off trimspool on
column usercreate format a1000
column useralter format a1000
spool ${Automate_DIR}/Scripts/SQL/${ORACLE_SID}/${DAY_DATE}/ExportAllUser_${ORACLE_SID}_${DAY_DATE}.sql;
select 'set termout on' from dual;

select 'ALTER PROFILE '||profile||' limit '||RESOURCE_NAME||' UNLIMITED;' 
 from dba_profiles where resource_name like 'PASSWORD_REUSE%'
order by profile;

select dbms_metadata.get_ddl('USER', username) usercreate from dba_users
UNION ALL
select replace(dbms_metadata.get_ddl('USER', username),'CREATE','ALTER') useralter from dba_users
UNION ALL
select
     dbms_metadata.get_ddl('DIRECTORY',directory_name)
from
     dba_directories
--UNION ALL
--SELECT DBMS_METADATA.GET_DDL('DB_LINK',a.db_link,a.owner) FROM dba_db_links a
UNION ALL
SELECT
(case
        when ((select count(*)
               from   dba_tab_privs
               where  grantee = d.username) > 0)
        then
                DBMS_METADATA.GET_GRANTED_DDL('OBJECT_GRANT', d.USERNAME)
        else  to_clob ('   -- Note: No Object Privileges found!')
        end )
FROM DBA_USERS d where username not in ('PERFSTAT','STDBYPERF','OUTLN','SYS','SYSMAN')
UNION ALL
SELECT (case
        when ((select count(*)
               from   dba_role_privs
               where  grantee = d.username) > 0)
        then
                DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT', d.USERNAME)
        else  to_clob ('   -- Note: No granted Roles found!')
        end )
FROM DBA_USERS d where username not in ('PERFSTAT','STDBYPERF','OUTLN','SYS','SYSMAN')
UNION ALL
SELECT (case
        when ((select count(*)
               from   dba_sys_privs
               where  grantee = d.username) > 0)
        then
                DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT', USERNAME)
        else  to_clob ('   -- Note: No System Privileges found!')
        end )
FROM DBA_USERS d where username not in ('PERFSTAT','STDBYPERF','OUTLN','SYS','SYSMAN')
UNION ALL
SELECT
(case
        when ((select count(*)
               from   dba_tab_privs
               where  grantee = r.role) > 0)
        then
                DBMS_METADATA.GET_GRANTED_DDL('OBJECT_GRANT', r.role)
        else  to_clob ('   -- Note: No Object Privileges found!')
        end )
FROM DBA_ROLES r where role in ('FCC_READONLY','FCC_DEPLOY','FCC_READWRITE','FCC_ADMIN','BRED_PUB_ROLE')
UNION ALL
SELECT (case
        when ((select count(*)
               from   dba_role_privs
               where  grantee = r.role) > 0)
        then
                DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT', r.role)
        else  to_clob ('   -- Note: No granted Roles found!')
        end )
FROM DBA_ROLES r where role in ('FCC_READONLY','FCC_DEPLOY','FCC_READWRITE','FCC_ADMIN','BRED_PUB_ROLE')
UNION ALL
SELECT (case
        when ((select count(*)
               from   dba_sys_privs
               where  grantee = r.role) > 0)
        then
                DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT', r.role)
        else  to_clob ('   -- Note: No System Privileges found!')
        end )
FROM DBA_ROLES r where role in ('FCC_READONLY','FCC_DEPLOY','FCC_READWRITE','FCC_ADMIN','BRED_PUB_ROLE');
select 'DROP ' || owner || ' DATABASE LINK ' || DB_LINK || ' ;' from dba_db_links where owner = 'PUBLIC';
spool off;

EOF

sed -i '/^;/d' ${Automate_DIR}/Scripts/SQL/${ORACLE_SID}/${DAY_DATE}/ExportAllUser_${ORACLE_SID}_${DAY_DATE}.sql
sed -i '/^ERROR/d' ${Automate_DIR}/Scripts/SQL/${ORACLE_SID}/${DAY_DATE}/ExportAllUser_${ORACLE_SID}_${DAY_DATE}.sql
sed -i '/^ORA-/d' ${Automate_DIR}/Scripts/SQL/${ORACLE_SID}/${DAY_DATE}/ExportAllUser_${ORACLE_SID}_${DAY_DATE}.sql
sed -i '/^   -- Note:/d' ${Automate_DIR}/Scripts/SQL/${ORACLE_SID}/${DAY_DATE}/ExportAllUser_${ORACLE_SID}_${DAY_DATE}.sql

cp ${Automate_DIR}/Scripts/SQL/${ORACLE_SID}/${DAY_DATE}/ExportAllUser_${ORACLE_SID}_${DAY_DATE}.sql /Automate/D-1/logs/${ORACLE_SID}/${DAY_DATE}/03-genalluser.log

echo "Step 03 export all user and password ${ORACLE_SID} ${DAY_DATE} done" | tee -a  /tmp/trace_refresh_${ORACLE_SID}_${DAY_DATE}.log
fi
