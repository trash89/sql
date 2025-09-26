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

@rest_sqp_set
