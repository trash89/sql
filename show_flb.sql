--
--  Script    : show_flb.sql
--  Purpose   : show the flashback info
--  Tested on : 10g,11g,12c,19c
--
@save_sqp_set

set lines 190 pages 50

col name    for a43
col value   for a100
ttitle left 'v$parameter : db_flashback_retention_target(in minutes), fast_start_mttr_target(in seconds), undo_retention(in seconds)'
SELECT
    name
   ,value
FROM
    gv$parameter
WHERE
    name IN ('db_flashback_retention_target','db_recovery_file_dest','db_recovery_file_dest_size','fast_start_mttr_target','undo_retention')
    AND inst_id=to_number(sys_context('USERENV','INSTANCE'))
ORDER BY
    name
;

clear columns
col OLDEST_FLASHBACK_SCN            head 'OLDEST FLASHBACK SCN'
col OLDEST_FLASHBACK_TIMEc  for a21 head 'OLDEST FLASHBACK TIME'
col retention_target                head 'Retention target(min)'
ttitle left 'Flashback settings - v$flashback_database_log : db_flashback_retention_target(in minutes)'
SELECT
    oldest_flashback_scn
   ,to_char(oldest_flashback_time,'dd/mm/yyyy hh24:mi:ss') as oldest_flashback_timec
   ,retention_target
   ,flashback_size
   ,estimated_flashback_size
FROM
    gv$flashback_database_log
WHERE
    inst_id=to_number(sys_context('USERENV','INSTANCE'))    
;

clear columns
col name    for a100
col fsize   for 99,999,999,999     head 'Size(MB)'
ttitle left 'Flashback settings - v$flashback_database_logfile'
SELECT 
     name
    ,(bytes/1024/1024) fsize
FROM 
    gv$flashback_database_logfile
WHERE 
    inst_id=to_number(sys_context('USERENV','INSTANCE'))
;

clear columns
col name                            for a30 head 'Restore Point Name'
col GUARANTEE_FLASHBACK_DATABASE    for a11 head 'Guaranteed?'
col fl_timec                        for a20 head 'Time'
col clean_pdb_restore_point         for a9  head 'Clean PDB'
ttitle left 'Restore Points - v$restore_point'
SELECT
    name
   ,DATABASE_INCARNATION#
   ,guarantee_flashback_database
   ,scn
   ,to_char(time,'dd/mm/yyyy hh24:mi:ss') as fl_timec
--   ,pdb_restore_point
--   ,clean_pdb_restore_point
FROM
    gv$restore_point
WHERE
    inst_id=to_number(sys_context('USERENV','INSTANCE'))    
;

@rest_sqp_set
