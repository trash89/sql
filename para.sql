set head off lines 200 
spool c:\tmp\para.sql
select 'alter table '||table_name||' parallel;' from user_tables
union all 
select 'alter index '||index_name||' parallel;' from user_indexes
;
spool off
@c:\tmp\para.sql

