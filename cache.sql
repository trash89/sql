set lines 150 pages 0 head off feed off
spool /tmp/cache.sql
select 'alter table '||owner||'.'||table_name||' nocache;' from dba_tables where owner not in ('SYS','SYSTEM');
spool off
set lines 80 pages 22 head on feed on
@/tmp/cache
