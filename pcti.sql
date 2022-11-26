spool /tmp/pcti.sql
set term off pages 0
select 'alter tablespace '||tablespace_name||' default storage(pctincrease 0);' from dba_tablespaces where pct_increase!=0;
select 'alter table '||owner||'.'||table_name||' storage(pctincrease 0);' from dba_tables where pct_increase!=0 and owner not in ('SYS','SYSTEM');
select 'alter index '||owner||'.'||index_name||' storage(pctincrease 0);' from dba_indexes where pct_increase!=0 and owner not in ('SYS','SYSTEM');
spool off
set term on pages 200
spool /tmp/pcti.log
@@/tmp/pcti.sql
spool off
host rm /tmp/pcti.sql

