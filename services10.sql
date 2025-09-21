--
--  Script    : services10.sql
--  Purpose   : show services
--  Tested on : 10g,11g,12c,19c
--
@save_sqp_set

set lines 90 pages 50
set feed off

col service_id      for 9999 head 'Id'
col name            for a30
col network_name    for a30
col creation_datec  for a20 head 'Creation'
ttitle left 'v$services'
SELECT 
     service_id
    ,name
    ,network_name
    ,to_char(creation_date,'dd/mm/yyyy hh24:mi:ss') as creation_datec
FROM 
    gv$services
WHERE    
    inst_id=to_number(sys_context('USERENV','INSTANCE'))    
ORDER BY 
    name    
;

set feed on
col con_name for a30
ttitle left 'v$active_services'
SELECT 
     service_id
    ,name
    ,network_name
    ,to_char(creation_date,'dd/mm/yyyy hh24:mi:ss') as creation_datec
FROM 
    gv$active_services
WHERE    
    inst_id=to_number(sys_context('USERENV','INSTANCE'))    
ORDER BY 
    name    
;

@rest_sqp_set
