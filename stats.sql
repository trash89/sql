set lines 150 pages 0 head off
spool /tmp/get_stats.sql
select 'exec dbms_stats.gather_schema_stats('||chr(39)||username||chr(39)||',cascade=>TRUE);' from dba_users
where username not in ('SYS','SYSTEM','DBSNMP','OUTLN');
spool off
set lines 150 pages 22 head on
@/tmp/get_stats
host rm -f /tmp/get_stats.sql
