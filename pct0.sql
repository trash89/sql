set lines 150 pages 0
spool /tmp/pct0.tmp
select 'alter table '||owner||'.'||table_name||' initrans 1 maxtrans 255 storage(pctincrease 0);' from dba_tables 
where owner not in ('SYS','SYSTEM');
select 'alter index '||owner||'.'||index_name||' initrans 2 maxtrans 255 storage(pctincrease 0);' from dba_indexes 
where owner not in ('SYS','SYSTEM');
spool off
@/tmp/pct0.tmp
host rm -f /tmp/pct0.tmp


