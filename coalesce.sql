set head off feed off pages 0 term off
spool /tmp/coalesce.sql
select 'ALTER TABLESPACE '||tablespace_name||' COALESCE;' from dba_tablespaces where status = 'ONLINE';
spool off;
set head on feed on pages 80 term on
@/tmp/coalesce.sql
host rm -f /tmp/coalesce.sql
