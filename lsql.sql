undef un_sid
@save_sqlplus_settings
set head off verify off autoprint off echo off show off tab off termout on trim off trims on newp none feed off lines 200 long 500000
accept un_sid number prompt 'Enter Session ID:'
column sql_fulltext format a300

spool target.sql
select sql_fulltext from
v$session a, v$sqlarea b 
where a.sql_address  = b.address and
      a.sql_hash_value=b.hash_value
and a.sid = &un_sid order by b.hash_value;
--,b.piece;
select ';' from dual;
spool off
undef un_sid
@restore_sqlplus_settings
