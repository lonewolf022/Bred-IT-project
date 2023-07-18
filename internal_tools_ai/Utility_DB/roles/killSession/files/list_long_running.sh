source /home/oracle/.bash_profile > /dev/null
export ORACLE_SID=$SID
\$ORACLE_HOME/bin/sqlplus '/ as sysdba' << EOF

set lin 500 pages 500
col DB_SESSION form a30
col DB_USER form a30
select DB_SESSION,DB_USER,STATUS,EXECUTION_TIME from
(select '('||s.sid||','||s.serial#||')' "DB_SESSION", s.USERNAME "DB_USER", s.LAST_CALL_ET "EXECUTION_TIME" , s.status "STATUS"
from v\\\$session s, v\\\$process P
where P.addr = s.paddr and s.type != 'BACKGROUND' and s.status = 'ACTIVE' and s.LAST_CALL_ET >= 3600
and s.username not in (select username from dba_users where profile in ('APP_PROFILE','DEFAULT','GSM_PROF','MONITORING_PROFILE','SYS_PROFILE'))
order by EXECUTION_TIME desc,DB_SESSION,DB_USER);
exit


exit;
EOF
