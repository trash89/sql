set head off lines 200 
spool c:\tmp\nopa.sql
select 'alter table '||table_name||' noparallel;' from user_tables
union all 
select 'alter index '||index_name||' noparallel;' from user_indexes
;
spool off
@c:\tmp\nopa.sql

