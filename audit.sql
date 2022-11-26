--
--  Script : audit.sql
--  Author : Marius RAICU
--  Purpose: create the audit_SCHEMA trigger for setting of the 10046 event, level 12
--  For    : 8i+
--
-----------------------------------------------------------------------------------------
undef sch
accept sch char prompt 'Schema?:' default ''
create or replace
trigger audit_&&sch
after logon on &&sch..schema
declare
  v_sid v$session.sid%type;
  v_serial# v$session.serial#%type;
begin
  select s.sid,s.serial# into v_sid,v_serial# 
  from v$session s
  where exists(select null from v$mystat m where m.sid=s.sid);
  dbms_system.set_ev(v_sid,v_serial#,10046,12,'');
end;
/

prompt The trigger is : audit_&&sch
