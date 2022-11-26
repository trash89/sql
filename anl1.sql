set lines 150 pages 0
spool /tmp/anl1.tmp
select 'analyze table '||owner||'.'||table_name||' delete statistics;' from dba_tables where owner not in ('SYS','SYSTEM','DBSNMP');
select 'analyze table '||owner||'.'||table_name||' compute statistics for table for all indexes for all columns size 75;' from dba_tables where owner not in ('SYS','SYSTEM','DBSNMP');
spool off
@/tmp/anl1.tmp
host rm -f /tmp/anl1.tmp
