--
--  Script    : setlogging.sql
--  Purpose   : execute alter table/index logging on tables/indexes for a schema owner
--  Tested on : 10g+
--
@save_sqp_set

set lines 200 pages 50
undef own
accept own char prompt 'Owner?(%)      : ' default ''
set head off autoprint off echo off show off tab off termout on newp none feed off lines 4096 long 5000000

spool /tmp/setlogging.sql
SELECT 
    'alter session set DDL_LOCK_TIMEOUT = 60;' 
FROM 
    dual
;

SELECT 
    'alter table "'||owner||'"."'||table_name||'" logging;' 
FROM dba_tables 
WHERE  
    owner LIKE upper('%&&own%')
    and logging='NO'
union all
SELECT 
    'alter index "'||owner||'"."'||index_name||'" logging;' 
FROM dba_indexes
WHERE  
--    index_type not in ('LOB') and
    owner LIKE upper('%&&own%')
    and logging='NO'
;
spool off

undef own

@rest_sqp_set

prompt Generating script /tmp/setlogging.sql 
prompt Run @/tmp/setlogging.sql to reset the logging clause on tables/indexes after un REBUILD/MOVE with nologging clauses
prompt
ed /tmp/setlogging.sql
