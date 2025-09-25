--
--  Script  : moni_rman.sql
--  Purpose : monitor a rman operation
--  For     : 11g+
--
@save_sqp_set

set lines 165 pages 50
col sidser          for a14     head 'sid,serial#'
col opname          for a30     head "Oper."
col pct_complete    for 999.99  head "% Comp."
col start_timec     for a17     head "Start|Time"
col hours_running   for 9999.99 head "Hours|Running"
col minutes_left    for 999,999 head "Minutes|Left"
col est_comp_time   for a17     head "Est. Comp.|Time"
ttitle left 'v$session_longops'
SELECT 
     to_char(sid)||','||to_char(serial#)  as sidser
    ,opname
    ,round(sofar/nullif(totalwork,0)*100,2)                                                                 as pct_complete
    ,to_char(start_time,'dd/mm/yyyy hh24:mi')                                                               as start_timec
    ,(sysdate-start_time)*24                                                                                as hours_running
    ,((sysdate-start_time)*24*60)/nullif((sofar/nullif(totalwork,0)),0) - (sysdate-start_time)*24*60        as minutes_left
    ,to_char((sysdate-start_time)/nullif((sofar/nullif(totalwork,0)),0) + start_time,'dd/mm/yyyy hh24:mi')  as est_comp_time
FROM 
    gv$session_longops
WHERE 
    upper(opname) LIKE '%RMAN%'
    AND upper(opname) NOT LIKE '%AGGREGATE%'
    AND totalwork != 0
    AND sofar <> totalwork
    AND inst_id=to_number(sys_context('USERENV','INSTANCE'))
;

col command_id              for a33
col operation               for a33
col start_timec             for a17     head "Start|Time"
col end_timec               for a17     head "End|Time"
col status                  for a23
col input_type              for a13     head "Input|type"
col input_bytes_display     for a10     head "Input|bytes"
col output_bytes_display    for a10     head "Output|bytes"
ttitle left 'rc_rman_backup_subjob_details'
SELECT
     command_id
    ,operation
    ,to_char(start_time,'dd/mm/yyyy hh24:mi') as start_timec
    ,to_char(end_time,'dd/mm/yyyy hh24:mi')   as end_timec
    ,status
    ,input_type
    ,input_bytes_display
    ,output_bytes_display
FROM
    rc_rman_backup_subjob_details
WHERE
    upper(status) like '%RUNNING%'
;


@rest_sqp_set
