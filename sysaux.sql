--
--  Script    : sysaux.sql
--  Purpose   : show sysaux tablespace occupants
--  Tested on : 12c,19c, for versions <12c, comment out -- sys_context('USERENV','CON_ID')=con_id
--
@save_sqp_set

set lines 50 pages 50
col occupant_name   for a35
col space           for 99,999,999.99 head 'Space(MB)'
break on report
compute sum of space on report

ttitle left 'v$sysaux_occupants'
SELECT 
     occupant_name
    ,SPACE_USAGE_KBYTES/1024 as space
FROM 
    gv$sysaux_occupants
WHERE    
    sys_context('USERENV','CON_ID')=con_id
    AND inst_id=to_number(sys_context('USERENV','INSTANCE'))
ORDER BY 
    space
;

break on report
compute sum of bytes on report
col owner for a30
ttitle left 'dba_segments'
SELECT 
     owner
    ,sum(bytes)/1024/1024 as space 
FROM 
    dba_segments
WHERE
    tablespace_name='SYSAUX'
GROUP BY 
    owner
ORDER BY 
    owner
;

@rest_sqp_set
