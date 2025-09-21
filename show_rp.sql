--
--  Script    : show_rp.sql
--  Purpose   : show the restore points
--  Tested on : 10g,11g,12c,19c
--
@save_sqp_set

set lines 100 pages 50

col name                            for a25
col timec                           for a20 head 'Time'
col GUARANTEE_FLASHBACK_DATABASE    for a12 head 'GuaranteeFlb'
ttitle left 'v$restore_point'
SELECT
    name
   ,to_char(time,'dd/mm/yyyy hh24:mi:ss') as timec
   ,guarantee_flashback_database
   ,scn
   ,DATABASE_INCARNATION#
FROM
    gv$restore_point
WHERE
    inst_id=to_number(sys_context('USERENV','INSTANCE'))
ORDER BY 
     time
    ,name    
;

@rest_sqp_set
