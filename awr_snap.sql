--
--  Script    : awr_snap.sql
--  Purpose   : show AWR info
--  Tested on : 10g,11g,12c,19c,23c, for versions <12c, comment out -- AND sys_context('USERENV','CON_ID')=con_id
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
WHERE
  begin_interval_time>trunc(systimestamp)
ORDER BY
  snap_id
;

undef start_snap_id
undef end_snap_id
prompt
accept start_snap_id number prompt 'Start Snap id    : '
accept end_snap_id number prompt 'End Snap id      : '
prompt

DECLARE
  mytask_name VARCHAR2(30):='marius_AWR_SNAPSHOT';
BEGIN
  BEGIN
    dbms_advisor.delete_task(mytask_name);
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;
  BEGIN
    dbms_advisor.reset_task(mytask_name);
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;
  dbms_advisor.create_task(advisor_name=>'ADDM',task_name=>mytask_name,task_desc=>'Advisor for snapshots.');
  dbms_advisor.set_task_parameter(task_name=>mytask_name,parameter=>'START_SNAPSHOT',value=>&&start_snap_id);
  dbms_advisor.set_task_parameter(task_name=>mytask_name,parameter=>'END_SNAPSHOT',value=>&&end_snap_id);
  dbms_advisor.execute_task(mytask_name);
END;
/
-- Display the report.
set lines 4096 long 5000000 PAGESIZE 50000
col report for a2048
spool /tmp/marius_AWR_SNAPSHOT.txt
SELECT dbms_advisor.get_task_report('marius_AWR_SNAPSHOT') AS report FROM dual;
spool off
undef start_snap_id
undef end_snap_id

@rest_sqp_set

ed /tmp/marius_AWR_SNAPSHOT.txt


-- @$ORACLE_HOME/rdbms/admin/awrrpt.sql
-- @$ORACLE_HOME/rdbms/admin/awrrpti.sql


-- exec DBMS_WORKLOAD_REPOSITORY.create_snapshot;
-- BEGIN
--   DBMS_WORKLOAD_REPOSITORY.modify_snapshot_settings(
--     retention => 43200,        --43200 Minutes (= 30 Days). Current value retained if NULL.
--     interval  => 30,           -- Minutes. Current value retained if NULL.
--     topnsql   => 100           -- top 100 sql statements
--   );          
-- END;
-- /
