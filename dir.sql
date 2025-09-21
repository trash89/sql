--
--  Script    : dir.sql
--  Purpose   : show directories for expdp/impdp
--  Tested on : 8i,9i,10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 199 pages 50
col owner           for a30
col directory_name  for a30
col DIRECTORY_PATH  for a130
col ORIGIN_CON_ID   for 99999 head 'con_id'
ttitle left 'dba_directories'
SELECT * 
FROM 
    dba_directories
ORDER BY 
     owner
    ,directory_name
;

@rest_sqp_set
