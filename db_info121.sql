--
--  Script    : db_info121.sql
--  Purpose   : show database info
--  Tested on : 12cR1,12cR2,19c,23c
--
@save_sqp_set

set lines 157 pages 50
set feed off

col property_name   for a40
col property_value  for a80
ttitle left 'database_properties'
SELECT
    property_name
   ,property_value
FROM
    database_properties
;

clear columns
col name    for a43
col value   for a74
col ses     for a8      head 'Sess?'
col sysm    for a9      head 'Sys?'
col pdb     for a9      head 'PDB?'
col inst    for a9      head 'Inst?'
ttitle left 'v$parameter'
SELECT
    name
   ,value
   ,isses_modifiable      AS ses
   ,issys_modifiable      AS sysm
   ,ispdb_modifiable      AS pdb
   ,isinstance_modifiable AS inst
FROM
    gv$parameter
WHERE
    isdefault='FALSE' or ismodified!='FALSE'
    AND inst_id=to_number(sys_context('USERENV','INSTANCE'))
ORDER BY
    name
;

clear columns
col name for a10
col OPEN_MODE           for a20
col FLASHBACK_ON        for a5      head 'Flash'
col FORCE_LOGGING       for a9      head 'Force Log'
col CONTROLFILE_TYPE    for a8      head 'CtrlFile'
col dmin                for a8      head 'SupplLog'
col dall                for a3      head 'All'
col fk                  for a3      head 'FK'
col pk                  for a3      head 'PK'
col ui                  for a3      head 'UI'
col pl                  for a3      head 'Pl'
ttitle left 'v$database'
SELECT
    name
   ,current_scn
   ,cdb
   ,open_mode
   ,log_mode
   ,flashback_on
   ,database_role
   ,force_logging
   ,controlfile_type
   ,supplemental_log_data_min                   as dmin
   ,supplemental_log_data_all                   as dall
   ,supplemental_log_data_fk                    as fk
   ,supplemental_log_data_pk                    as pk
   ,supplemental_log_data_ui                    as ui
   ,supplemental_log_data_pl                    as pl
   ,to_char(created,'dd/mm/yyyy hh24:mi:ss')    as created
FROM
    gv$database
WHERE
    inst_id=to_number(sys_context('USERENV','INSTANCE'))
;

ttitle off
col open_resetlogs      for a15
col PROTECTION_MODE     for a20
col PROTECTION_LEVEL    for a20
col REMOTE_ARCHIVE      for a10 head 'RemoteArch'
col SWITCHOVER_STATUS   for a20
col DATAGUARD_BROKER    for a8  head 'DGBroker'
col GUARD_STATUS        for a12 head 'Guard Status'
SELECT 
     open_resetlogs
    ,PROTECTION_MODE
    ,PROTECTION_LEVEL
    ,REMOTE_ARCHIVE
    ,SWITCHOVER_STATUS
    ,DATAGUARD_BROKER
    ,GUARD_STATUS 
FROM 
    gv$database 
WHERE
    inst_id=to_number(sys_context('USERENV','INSTANCE'))     
;

col platform_id         for 999999  head 'PlatId'
col platform_name       for a26
col endian_format       for a6      head 'Endian'
SELECT
    d.platform_id
   ,d.platform_name
   ,t.endian_format
FROM
    gv$database d,
    gv$transportable_platform t
WHERE
    d.inst_id=t.inst_id
    AND d.inst_id=to_number(sys_context('USERENV','INSTANCE')) 
    AND d.platform_id=t.platform_id
;

clear columns
col STATUS      for a8
col megs        for 999,999,999 head 'Size(MB)'
col FILENAME    for a100
ttitle left 'v$block_change_tracking'
SELECT
     status
    ,bytes/1024/1024 as megs        
    ,filename
FROM
    v$block_change_tracking
;

col type for a9
col megs for 999,999,999 head 'Size(MB)'
col name for a100
ttitle left 'v$flashback_database_logfile'
SELECT 
     type
    ,bytes/1024/1024 as megs
    ,name
FROM 
    gv$flashback_database_logfile
WHERE
    inst_id=to_number(sys_context('USERENV','INSTANCE'))     
;

clear columns
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
col OLDEST_FLASHBACK_SCN                head 'OLDEST FLASHBACK SCN'
col OLDEST_FLASHBACK_TIMEc      for a21 head 'OLDEST FLASHBACK TIME'
col retention_target                    head 'Retention target(min)'
col flashback_size              for 999,999,999,999.99
col estimated_flashback_size    for 999,999,999,999.99
ttitle left 'Flashback settings - V$flashback_database_log, flashback_size in MB'
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
FROM
    gv$restore_point
WHERE
    inst_id=to_number(sys_context('USERENV','INSTANCE'))    
;

clear columns
col name            for a15
col restricted      for a10
col recovery_status for a15
col backup_status   for a15
col PDB_SIZE_GB     for 999,999,999.99
ttitle left 'v$pdbs'
SELECT
    name
   ,open_mode
   ,restricted
   ,recovery_status
   ,total_size/1024/1024/1024 as PDB_SIZE_GB
FROM
    gv$pdbs
WHERE   
    inst_id=to_number(sys_context('USERENV','INSTANCE'))
;

clear columns
col RESETLOGS_TIMEc         for a20 head 'Resetlogs Time'
col PRIOR_RESETLOGS_TIMEc   for a20 head 'Prior Resetlogs Time'
ttitle left 'v$database_incarnation'
SELECT 
     INCARNATION#
    ,RESETLOGS_CHANGE#
    ,to_char(RESETLOGS_TIME,'dd/mm/yyyy hh24:mi:ss') as RESETLOGS_TIMEc
    ,PRIOR_RESETLOGS_CHANGE#
    ,to_char(PRIOR_RESETLOGS_TIME,'dd/mm/yyyy hh24:mi:ss') as PRIOR_RESETLOGS_TIMEc
    ,STATUS
    ,FLASHBACK_DATABASE_ALLOWED
FROM 
    gv$database_incarnation
WHERE
    inst_id=to_number(sys_context('USERENV','INSTANCE'))
ORDER BY 
    1
;

@rest_sqp_set
