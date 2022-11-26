set lines 150 pages 0 head off
spool /tmp/moniidx.sql
select 'alter index '||owner||'.'||index_name||' monitoring usage;' from dba_indexes
where owner not in ('SYS','SYSTEM','DBSNMP','OUTLN');
spool off
set lines 150 pages 22 head on
@/tmp/moniidx
host rm -f /tmp/moniidx.sql
