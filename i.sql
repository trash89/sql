--
--  Script    : i.sql
--  Purpose   : show invalid objects and unusable indexes
--  Tested on : 8i,9i,10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 150 pages 50
col obj             for a60
col index_owner     for a25
col index_name      for a25
col partition_name  for a25
col object_type     for a25
col status          for a10

SELECT * FROM (
SELECT owner||'.'||object_name as obj,object_type,status
FROM 
    dba_objects 
WHERE 
    status!='VALID'
UNION ALL
SELECT owner||'.'||index_name as obj,'INDEX',status 
FROM 
    dba_indexes 
WHERE 
    status NOT IN ('VALID','N/A')
UNION ALL
SELECT index_owner||'.'||index_name as obj,partition_name,status
FROM 
    dba_ind_partitions
WHERE 
    status NOT IN ('USABLE','VALID','N/A')
)
ORDER BY 
     obj
    ,object_type
;

prompt
prompt Run to compile 
prompt @?/rdbms/admin/utlrp
prompt

@rest_sqp_set