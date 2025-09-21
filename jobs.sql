--
--  Script    : jobs.sql
--  Purpose   : show info FROM dba_scheduler_jobs, dba_autotask_job_history, dba_autotask_task, dba_scheduler_programs, dba_jobs,dba_jobs_running
--  Tested on : 10g,11g,12c,19c
--
@save_sqp_set

set lines 180 pages 50

col job_name        for a35 head "JobName"
col what            for a35 head 'What'
col lastc           for a12 head 'Last'
col nextc           for a12 head 'Next'
col failure_count   for 9,999 head 'Fail'
col enabled         for a5  head 'Enabl'
col logpriv         for a60 head "Owner/ProgOwn"
ttitle left 'dba_scheduler_jobs'
SELECT
    a.job_name
   ,substr(a.program_name,instr(a.program_name,':='),23)    what
   ,to_char(a.last_start_date,'dd/mm HH24:MI')              lastc
   ,to_char(a.next_run_date,'dd/mm HH24:MI')                nextc
   ,a.failure_count
   ,a.enabled
   ,substr(a.owner||'/'||a.program_owner,1,60) as logpriv
FROM
    dba_scheduler_jobs         a
   ,dba_scheduler_running_jobs b
WHERE
    b.owner(+)=a.owner
    AND b.job_name(+)=a.job_name
ORDER BY
    a.last_start_date
;
clear columns

col client_name     for a35
col task_name       for a35
col operation_name  for a35
col job_name        for a35
col job_status      for a10
col job_duration    for a15
col job_start_timec for a16
ttitle left 'dba_autotask_job_history'
SELECT * FROM (
SELECT
    client_name
   ,job_name
   ,job_status
   ,to_char(job_start_time,'dd/mm/yyyy hh24:mi') as job_start_timec
   ,job_duration
FROM
    dba_autotask_job_history
WHERE
    job_start_time<systimestamp-5    
ORDER BY
    job_start_time
   ,client_name
)
WHERE 
    rownum<51
;

clear columns
col client_name     for a35
col task_name       for a35
col operation_name  for a35
col last_good_datec for a16
ttitle left 'dba_autotask_task'
SELECT
    client_name
   ,task_name
   ,operation_name
   ,status
   ,to_char(last_good_date,'dd/mm/yyyy hh24:mi') as last_good_datec
FROM
    dba_autotask_task
ORDER BY
    last_good_date
;

col CLIENT_NAME for a31
ttitle left 'dba_autotask_client'
SELECT
    client_name
   ,status
FROM
    dba_autotask_client
;

ttitle left 'dba_scheduler_programs'
col owner           for a25
col program_name    for a25
SELECT
    owner
   ,program_name
   ,enabled
FROM
    dba_scheduler_programs
;

col job       for 999999 head "Job#"
col what      for a120   head "What"
col Last      for a12    head "Last"
col Next      for a12    head "Last"
col fail      for a8     head "F/B/Sid"
col logpriv   for a30    head "LogUser/PrivUser"
ttitle left 'dba_jobs, dba_jobs_running'
SELECT
  a.job
 ,substr(a.what,instr(a.what,':='),120)                                 AS what
 ,to_char(a.last_date,'dd/mm HH24:MI')                                  AS Last
 ,to_char(a.next_date,'dd/mm HH24:MI')                                  AS Next
 ,to_char(nvl(a.failures,0))||'/'||a.broken||'/'||to_char(nvl(b.sid,0)) as fail
 ,a.log_user||'/'||a.priv_user                                          AS logpriv
FROM
  dba_jobs         a
 ,dba_jobs_running b
WHERE
  b.job(+)=a.job
ORDER BY
  next_date DESC
;

@rest_sqp_set
