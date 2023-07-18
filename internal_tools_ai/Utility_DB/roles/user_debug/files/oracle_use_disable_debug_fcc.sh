#!/bin/bash
#This script is use for disable debug flexcube for user = parameter or connected user
#execute by ./disable_debug_fcc.sh $ORACLE_SID username
#or leave it blank for current user ./disable_debug_fcc.sh $ORACLE_SID

. /home/oracle/.bash_profile
ORACLE_SID=$1
now=`date +"%Y%m%d_%H%M%S"`
first=$3
fccuser=$2
#Get username ======================================
NRDATE=`$ORACLE_HOME/bin/sqlplus -s /nolog <<!!
connect /
set heading off pages 0 feedback off tab off
SELECT replace(upper(SYS_CONTEXT('USERENV','OS_USER')),'ADM_','') FROM DUAL
/
!!
`
#==================================================================

#if parameter is null then will enable for user_id=connected user

if [ -z "$1" ]
then
first=$NRDATE
fi
echo $first

$ORACLE_HOME/bin/sqlplus -s "/as sysdba" <<-EOF
WHENEVER OSERROR EXIT 1;
WHENEVER SQLERROR EXIT 1;
set echo off
set termout off
set feedback off
set pages 0
spool $HOME/disable_debug_$first_$now.log
declare
begin

--#This update is for disable debug for all user, at production need to disable all
update $fccuser.cstb_param set param_val = 'N' where param_name = 'REAL_DEBUG' ;
update $fccuser.cstb_debug_users set debug = 'N' where user_id = '$first';
commit;
end;
/
select * from $fccuser.cstb_param  where param_name = 'REAL_DEBUG' ;
spool off;
EOF

#echo " " `tail -n10 $HOME/disable_debug_$first_$now.log` |mutt -e 'set from=BBF-DEV.Monitoring@bred-it.com' -s "[BBF-DEV PRD disable debug] disable debug for user ${first}" -- support.goc@bred-it.com,support.dba@bred-it.com
