--
--  Script    : dg_info.sql
--  Purpose   : show Dataguard info
--  Tested on : 12c,19c,23c
--
@save_sqp_set

set lines 190 pages 50
set feed off

col timestampc  for a20 head 'Timestamp'
col message     for a120
ttitle left 'v$dataguard_status'
SELECT
    to_char(timestamp,'dd/mm/yyyy hh24:mi:ss') as timestampc
   ,severity
   ,facility
   ,message
FROM
    gv$dataguard_status
WHERE
    inst_id=to_number(sys_context('USERENV','INSTANCE'))
    AND trunc(timestamp)=trunc(sysdate)
ORDER BY
    timestamp    
;

clear columns
col con_id  for 99 head 'Con'
ttitle left 'v$dataguard_config'
SELECT *
FROM
    gv$dataguard_config
;

col CLIENT_PROCESS for a14 head 'Client Process'
ttitle left 'v$managed_standby : Real-Time Apply if MRP0 process status is in APPLYING_LOG; otherwise in WAIT_FOR_LOG'
SELECT 
     THREAD#
    ,SEQUENCE#
    ,PROCESS
    ,CLIENT_PROCESS
    ,STATUS
    ,BLOCKS
FROM 
    gv$managed_standby
WHERE
    inst_id=to_number(sys_context('USERENV','INSTANCE'))
;

clear columns
ttitle left 'v$dataguard_process'
SELECT
    name
   ,type
   ,stop_state
   ,action
   ,client_role
   ,role
   ,group#
   ,thread#
   ,sequence#
FROM
    gv$dataguard_process
WHERE
    inst_id=to_number(sys_context('USERENV','INSTANCE'))     
;

clear columns
col inst_id                 for 999 head 'Inst'
col SOURCE_DB_UNIQUE_NAME   for a21
col name                    for a30
col value                   for a20
col TIME_COMPUTED           for a19
col DATUM_TIME              for a19
col con_id                  for 99 head 'Con'
ttitle left 'v$dataguard_stats'
SELECT *
FROM
    gv$dataguard_stats
WHERE
    inst_id=to_number(sys_context('USERENV','INSTANCE'))     
;

clear columns
col name                for a64
col unit                for a16
col last_time_updated   for a20
ttitle left 'v$standby_event_histogram, only count > 20'
SELECT * 
FROM 
    v$standby_event_histogram 
WHERE 
    NAME = 'apply lag' 
    AND COUNT > 20
;

---- Logical Standby views

col dbeg        for a4      head 'DBeg'
col dend        for a4      head 'DEnd'
col timestampc  for a20     head 'Timestamp'
col FILE_NAME   for a130
ttitle left 'dba_logstdby_log (Logical Standby)'
SELECT 
     SEQUENCE#
    ,DICT_BEGIN as dbeg
    ,DICT_END as dend
    ,APPLIED
    ,to_char(timestamp,'dd/mm/yyyy hh24:mi:ss') as timestampc
    ,FILE_NAME
FROM 
    dba_logstdby_log
WHERE 
    trunc(timestamp)=trunc(sysdate)
ORDER BY 
    SEQUENCE#
;

col con_id  for 99 head 'Con'
ttitle left 'v$logstdby_state (Logical Standby)'
SELECT * 
FROM 
    v$logstdby_state
;

col sidser  for a14     head 'sid,serial#'
col type    for a30
col status  for a100
ttitle left 'v$logstdby_process (Logical Standby)'
SELECT 
     to_char(sid)||','||to_char(serial#)  as sidser
    ,TYPE
    ,STATUS_CODE
    ,STATUS 
FROM 
     v$logstdby_process
;

@rest_sqp_set
