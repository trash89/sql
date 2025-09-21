--
--  Script    : options.sql
--  Purpose   : show options FROM v$options
--  Tested on : 10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 70 pages 50

col parameter  for a40
col value for a10
ttitle left 'v$option'
SELECT 
     parameter
    ,value
FROM 
    gv$option
WHERE
    inst_id=to_number(sys_context('USERENV','INSTANCE'))    
ORDER BY 
    parameter    
;

@rest_sqp_set
