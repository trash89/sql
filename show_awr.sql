--
--  Script    : show_awr.sql
--  Purpose   : show snap_id FROM AWR (dba_hist_snapshot)
--  Tested on : 10g,11g,12c,19c
--
@save_sqp_set

set lines 100 pages 50
col begin_interval_timec  for a20 head 'Begin Interval'
col end_interval_timec    for a20 head 'End Interval'
col startup_timec         for a20 head 'DB Startup time'
col dbid                  for 999999999999999
col con_id                for 999 head 'Con'
ttitle left 'dba_hist_snapshot'
SELECT
    snap_id
   ,to_char(begin_interval_time,'dd/mm/yyyy hh24:mi') begin_interval_timec
   ,to_char(end_interval_time,'dd/mm/yyyy hh24:mi')   end_interval_timec
   ,to_char(startup_time,'dd/mm/yyyy hh24:mi')        startup_timec
   ,dbid
   ,con_id
FROM
    dba_hist_snapshot
ORDER BY
    snap_id
;

@rest_sqp_set
