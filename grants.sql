undef newuser
undef crtuser
accept newuser char prompt 'UserName:'
column crtuser new_value crtuser
select username crtuser from user_users;
set lines 150 pages 0 head off feed off verify off
spool /tmp/tab.sql
select 'grant select,insert,update,delete on '||object_name||' to &&newuser;' from user_objects where object_type='TABLE';
select 'grant select on '||view_name||' to &&newuser;' from user_views;
select 'grant select on '||sequence_name||' to &&newuser;' from user_sequences;
select distinct 'grant execute on '||name||' to &&newuser;' from user_source
where type in ('FUNCTION','PACKAGE','PROCEDURE');
select 'drop synonym &&newuser'||'.'||object_name||';' from user_objects where object_type in ('TABLE','VIEW','PROCEDURE','FUNCTION','SEQUENCE','PACKAGE');	
select 'create synonym &&newuser'||'.'||object_name||' for &crtuser.'||'.'||object_name||';' from user_objects where object_type in ('TABLE','VIEW','PROCEDURE','FUNCTION','SEQUENCE','PACKAGE');	
spool off
set head on feed on verify on
spool /tmp/grants.log
@/tmp/tab
spool off
undef newuser
undef crtuser
ed /tmp/grants.log
