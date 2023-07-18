#!/bin/bash
#This script is use for enable debug flexcube for user = parameter or connected user
#execute by ./enable_debug_fcc.sh username
#or leave it blank for current user ./enable_debug_fcc.sh

. /home/oracle/.bash_profile

echo "#This script is use for enable debug flexcube for user = parameter or connected user"
echo "#execute by ./enable_debug_fcc.sh username"
echo "#or leave it blank for current user ./enable_debug_fcc.sh"

now=`date +"%Y%m%d_%H%M%S"`
first=$3
fccuser=$2
export ORACLE_SID=$1
HOME=/home/oracle/Scripts/bin/log
export HOME

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
tempupperfirst=`echo $first | tr [a-z] [A-Z]`
first=$tempupperfirst

$ORACLE_HOME/bin/sqlplus -s "/as sysdba" <<-EOF
WHENEVER OSERROR EXIT 1;
WHENEVER SQLERROR EXIT 1;
set echo off
set pages 0
spool $HOME/enable_debug_$first_$now.log
declare
c_user integer;
begin
select count(*) into c_user from $fccuser.cstb_debug_users where user_id='$first';

if c_user=0 then
        insert into $fccuser.cstb_debug_users select module,debug,'$first'
         from  $fccuser.cstb_debug_users where user_id = 'SYSTEM';
end if;

update $fccuser.cstb_param set param_val = 'Y' where param_name = 'REAL_DEBUG' ;
update $fccuser.cstb_debug_users set debug = 'Y' where user_id = '$first';
update $fccuser.gwtb_parameters set param_value = 'Y' where param_name = 'DEBUG_MODE';
commit;
end;
/
spool off;

select * from $fccuser.cstb_param  where param_name = 'REAL_DEBUG' ;

select directory_path "Debug Directory Path"
from sys.dba_directories
where directory_name=
(select param_val  from $fccuser.cstb_param where param_name='WORK_AREA');
EOF

#echo " " `tail -n10 $HOME/enable_debug_$first_$now.log` |mutt -e 'set from=BBF.Monitoring@bred-it.com' -s "[BBF PRD enable debug] enable debug for user ${first}" -- support.goc@bred-it.com,support.dba@bred-it.com
