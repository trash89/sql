--
--  Script    : aud.sql
--  Purpose   : display information FROM dba_audit_trail
--  Tested on : 8i +
--
@save_sqp_set

set lines 120 pages 50
col os            for a25
col username      for a15
col timestamp     for a14
col obj           for a25
col action_name   for a10
ttitle left 'dba_audit_trail'
SELECT
   to_char(timestamp,'dd/mm/rr hh24:mi')  as timestamp
  ,terminal||'-'||os_username            os
  ,username
  ,owner||'.'||obj_name                  AS obj
  ,action_name
FROM
   dba_audit_trail
ORDER BY
   TIMESTAMP
  ,os_username
;

col parameter_name for a30
col parameter_value for a30
SELECT * FROM DBA_AUDIT_MGMT_CONFIG_PARAMS;

@rest_sqp_set

-- DELETE FROM sys.aud$ WHERE timestamp# < SYSDATE -90;
-- exec DBMS_AUDIT_MGMT.SET_AUDIT_TRAIL_LOCATION(AUDIT_TRAIL_TYPE=> DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD, AUDIT_TRAIL_LOCATION_VALUE => 'SYSAUX');


--BEGIN
--   DBMS_AUDIT_MGMT.INIT_CLEANUP(audit_trail_type=> DBMS_AUDIT_MGMT.AUDIT_TRAIL_ALL,default_cleanup_interval=> 12 /* hours */);
--END;
--/

--REM Enable Automated Audit Trail Cleanup - 60 days
--set serveroutput on
--REM Set Archive TimeStamp - delete records older than 60 days
--begin
--   dbms_audit_mgmt.set_last_archive_timestamp(audit_trail_type=>dbms_audit_mgmt.AUDIT_TRAIL_OS,last_archive_time=>systimestamp-60);
--end;
--/

--begin
--   dbms_audit_mgmt.set_last_archive_timestamp(audit_trail_type=>dbms_audit_mgmt.AUDIT_TRAIL_AUD_STD,last_archive_time=>systimestamp-60);
--end;
--/


--REM Onetime Manual Purge
--begin
--   dbms_audit_mgmt.clean_audit_trail(audit_trail_type => dbms_audit_mgmt.AUDIT_TRAIL_ALL,use_last_arch_timestamp => true);
--end;
--/

--REM Create Purge Job for Automated Purging
--begin
--   dbms_audit_mgmt.create_purge_job(
--      audit_trail_type => dbms_audit_mgmt.AUDIT_TRAIL_ALL,
--      audit_trail_purge_interval => 24 /* 1 day */ ,
--      audit_trail_purge_name => 'PURGE_DB_AUDIT_RECORDS',
--      use_last_arch_timestamp => true);
--end;
--/

--REM Schedule a Job for adjusting the archived date
--REM Records are not archived, but need deleted after 60 days
--begin
--   dbms_scheduler.create_job (
--      job_name => 'SET_AUDIT_ARCHIVE_DATE',
--      job_type => 'PLSQL_BLOCK',
--      job_action => 'DBMS_AUDIT_MGMT.set_last_archive_timestamp(audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,last_archive_time => SYSTIMESTAMP-60);',
--      start_date => systimestamp,
--      repeat_interval => 'freq=daily; byhour=20',
--      end_date => null,
--      enabled => true,
--      comments => 'Job to support automatic audit trail purge');
--end;
--/
