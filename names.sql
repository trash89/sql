
--
--  Script    : names.sql
--  Purpose   : show the different names of the database AND instance
--  Tested on : 12c,19c
--
@save_sqp_set

set lines 50 pages 50
set feed off

col name    for a20
col value   for a20
ttitle left 'names FROM v$parameter'
SELECT 
     name
    ,value 
FROM 
    gv$parameter 
WHERE 
    name in ('db_name','db_unique_name','instance_name','cdb_cluster_name')
    AND inst_id=to_number(sys_context('USERENV','INSTANCE'))
;

col instance_name for a16
ttitle left 'instance_name FROM v$instance'
SELECT 
    instance_name 
FROM 
    gv$instance
WHERE
    inst_id=to_number(sys_context('USERENV','INSTANCE'))
;

col name for a9
ttitle left 'name FROM v$database'
SELECT name 
FROM 
    gv$database
WHERE 
    inst_id=to_number(sys_context('USERENV','INSTANCE'))    
;

col global_name for a20
ttitle left 'global_name FROM global_name'
SELECT 
    * 
FROM 
    global_name
;

col db_unique_name for a20
ttitle left 'db_unique_name FROM sys_context'
SELECT 
    sys_context('USERENV','DB_UNIQUE_NAME') as db_unique_name 
FROM 
    dual
;

col instance for 99 head 'Instance'
ttitle left 'instance number FROM sys_context'
SELECT 
    to_number(sys_context('USERENV','INSTANCE')) as instance 
FROM 
    dual
;

prompt

@rest_sqp_set
