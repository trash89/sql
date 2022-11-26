set lines 110 pages 200 head off feed off
spool /tmp/rb_on.sql
select 'alter rollback segment '||segment_name||' online;' from dba_rollback_segs where owner!='SYS';
spool off
set lines 80 pages 22 head on feed on
@/tmp/rb_on
host rm -f /tmp/rb_on.sql

