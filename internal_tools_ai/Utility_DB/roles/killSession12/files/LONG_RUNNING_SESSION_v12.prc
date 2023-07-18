grant select on v_$session to SYSTEM;
grant select on v_$process to SYSTEM;
grant select on v_$sqltext to SYSTEM;
grant alter system to SYSTEM;

-----------------------


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
