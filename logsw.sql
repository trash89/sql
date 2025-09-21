--
--  Script    : logsw.sql
--  Purpose   : show redo log switches
--  Tested on : 10g,11g,12c,19c
--
@save_sqp_set

set lines 80 pages 50
set echo off 

set term off feed off
column sequence# new_value m_sequence
SELECT  max(sequence#) sequence# FROM gv$log WHERE inst_id=to_number(sys_context('USERENV','INSTANCE'));
set term on feed on
ttitle left 'v$log_history'
SELECT
    to_char(first_time,'dd/mm/yyyy hh24:mi:ss')                                     as first_time,
    round(24 * 60 * (lead(first_time,1) over (ORDER BY first_time) - first_time),2) as minutes
FROM
    gv$log_history v
WHERE
    recid >= &m_sequence - 30
    AND v.inst_id=to_number(sys_context('USERENV','INSTANCE'))
ORDER BY
    recid
;

@rest_sqp_set
