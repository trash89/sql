--
--  Script    : dp_jobs.sql
--  Purpose   : show Datapump jobs currently running
--  Tested on : 10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 130 pages 50
col owner_name for a25
col job_name for a25
col job_mode for a15
col state for a20
ttitle left 'dba_datapump_jobs, dba_datapump_sessions'
SELECT
    j.owner_name
   ,j.job_name
   ,j.job_mode
   ,j.state
   ,s.session_type
   ,s.saddr
FROM
    dba_datapump_jobs     j
   ,dba_datapump_sessions s
WHERE
    upper(j.job_name)=upper(s.job_name)
;

@rest_sqp_set
