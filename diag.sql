--
--  Script    : diag.sql
--  Purpose   : show v$diag_info
--  Tested on : 11g,12c,19c,23c
--
@save_sqp_set

set lines 130 pages 50 feed off

col name  for a25
col value for a100
ttitle left 'v$diag_info'
SELECT 
     name
    ,value
FROM 
    gv$diag_info
WHERE
    inst_id=to_number(sys_context('USERENV','INSTANCE'))    
;

set head off
SELECT 'To view the alert.log : host vi '||di.value||'/alert_'||p.value||'.log' as v
FROM 
    gv$diag_info di,
    gv$parameter p
WHERE
    di.name='Diag Trace'
    AND p.name='db_name'
    AND di.inst_id=to_number(sys_context('USERENV','INSTANCE'))
    AND di.inst_id=p.inst_id
;

@rest_sqp_set
