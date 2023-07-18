grant select on v_$session to SYSTEM;
grant select on v_$process to SYSTEM;
grant select on v_$sqltext to SYSTEM;
grant alter system to SYSTEM;

-----------------------

CREATE or replace PROCEDURE system.CHECK_LONG_RUNNING_SESSION
AS
  c1 SYS_REFCURSOR;
BEGIN
  open c1 for
     select DB_SESSION||'  '||DB_USER||'  '||STATUS||'  '||EXECUTION_TIME as "DB_SESSION    DB_USER    STATUS    EXECUTION_TIME" from
     (select '('||s.sid||','||s.serial#||')' "DB_SESSION", s.USERNAME "DB_USER", s.LAST_CALL_ET "EXECUTION_TIME" , s.status "STATUS"
     from v$session s, v$process P
--   where P.addr = s.paddr and s.type != 'BACKGROUND' and s.status = 'ACTIVE' and s.LAST_CALL_ET >= 3600
     where P.addr = s.paddr and s.type != 'BACKGROUND' and s.status = 'ACTIVE' and s.LAST_CALL_ET >= 3600
     and s.username not in ('APP_ACTIVECUST','APP_AML','APP_AUTOMATE','APP_AUTOMATE_DDL','APP_BASEL','APP_COMMERCIAL','APP_CRR','APP_CTRLM','APP_IFRS9',
     'BACKUPDB','BCIDWHEOD','BCIDWHEOM','DWHEOD','DWHEOM','DWHREADFCDB',
     'FCCBCIODT','FCCBCIPROD','FCCBBFPROD','FCCBCIREAD','FCC_IAU','FCC_IAU_APPEND','FCC_IAU_VIEWER','FCC_OPSS','FCC_STB','FCC_WLS','FCC_WLS_RUNTIME',
     'FCATBBFAPP','FCATBBFPROD','FCATREAD','FCCBACKUP','FCCBBFODT','FCCBBFPROD','FCCBBFREAD','FCCDEV_IAU','FCCDEV_IAU_APPEND','FCCDEV_IAU_VIEWER','FCCDEV_MDS','FCCDEV_OPSS','FCCDEV_STB','FCCDEV_WLS','FCCDEV_WLS_RUNTIME',
     'OBIEE_REPO','SVC_BIP','SYS','SYSTEM')
     order by EXECUTION_TIME desc,DB_SESSION,DB_USER);
  DBMS_SQL.RETURN_RESULT(c1);
END;
/

-----------------------------------------

grant execute on system.CHECK_LONG_RUNNING_SESSION to APP_AUTOMATE;
grant execute on system.CHECK_LONG_RUNNING_SESSION to APP_AUTOMATE_DDL;
create synonym APP_AUTOMATE.CHECK_LONG_RUNNING_SESSION for system.CHECK_LONG_RUNNING_SESSION ;
create synonym APP_AUTOMATE_DDL.CHECK_LONG_RUNNING_SESSION for system.CHECK_LONG_RUNNING_SESSION ;

------------------------------------------

create or replace procedure system.KILL_LONG_RUNNING_SESSION (pn_sid number,pn_serial number)	as
lv_user varchar2(30);
	begin
	select username into lv_user from v$session where sid = pn_sid and serial# = pn_serial;
	if lv_user is not null and lv_user not in ('APP_ACTIVECUST','APP_AML','APP_AUTOMATE','APP_AUTOMATE_DDL','APP_BASEL','APP_COMMERCIAL','APP_CRR','APP_CTRLM','APP_IFRS9',
        'BACKUPDB','BCIDWHEOD','BCIDWHEOM','DWHEOD','DWHEOM','DWHREADFCDB',
        'FCCBCIODT','FCCBCIPROD','FCCBBFPROD','FCCBCIREAD','FCC_IAU','FCC_IAU_APPEND','FCC_IAU_VIEWER','FCC_OPSS','FCC_STB','FCC_WLS','FCC_WLS_RUNTIME',
        'FCATBBFAPP','FCATBBFPROD','FCATREAD','FCCBACKUP','FCCBBFODT','FCCBBFPROD','FCCBBFREAD','FCCDEV_IAU','FCCDEV_IAU_APPEND','FCCDEV_IAU_VIEWER','FCCDEV_MDS','FCCDEV_OPSS','FCCDEV_STB','FCCDEV_WLS','FCCDEV_WLS_RUNTIME',
        'OBIEE_REPO','SVC_BIP','SYS','SYSTEM')
        then
	execute immediate 'alter system kill session '''||pn_sid||','||pn_serial||'''';
	else
        raise_application_error(-20000,'Attempt to kill protected application session or system session has been blocked.');
	end if;
	end;
	/


grant execute on system.KILL_LONG_RUNNING_SESSION to APP_AUTOMATE;
grant execute on system.KILL_LONG_RUNNING_SESSION to APP_AUTOMATE_DDL;
create synonym APP_AUTOMATE.KILL_LONG_RUNNING_SESSION for system.KILL_LONG_RUNNING_SESSION ;
create synonym APP_AUTOMATE_DDL.KILL_LONG_RUNNING_SESSION for system.KILL_LONG_RUNNING_SESSION ;

---------------------------------------------------

CREATE or replace PROCEDURE system.CHECK_STATEMENT_LONG_RUNNING (pn_sid number,pn_serial number)  AS
  c1 SYS_REFCURSOR;
BEGIN
  open c1 for
     select sql_text from v$session se, v$sqltext st
          where se.SQL_HASH_VALUE  = st.hash_value  and se.sid = pn_sid
          order by se.sid , st.address, st.piece;
  DBMS_SQL.RETURN_RESULT(c1);
END;
/


grant execute on system.CHECK_STATEMENT_LONG_RUNNING to APP_AUTOMATE;
grant execute on system.CHECK_STATEMENT_LONG_RUNNING to APP_AUTOMATE_DDL;
create synonym APP_AUTOMATE.CHECK_STATEMENT_LONG_RUNNING for system.CHECK_STATEMENT_LONG_RUNNING ;
create synonym APP_AUTOMATE_DDL.CHECK_STATEMENT_LONG_RUNNING for system.CHECK_STATEMENT_LONG_RUNNING ;
exit;
-------------------------------------------------------------
