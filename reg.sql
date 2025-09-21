--
--  Script    : reg.sql
--  Purpose   : show options FROM dba_registry
--  Tested on : 12c,19c,23c
--
@save_sqp_set

set lines 100 pages 50

col comp_id     for a10
col comp_name   for a60
col status      for a20
ttitle left 'dba_registry'
SELECT 
     comp_id
    ,comp_name
    ,status 
FROM 
    dba_registry
ORDER BY 
    1
;

@rest_sqp_set
