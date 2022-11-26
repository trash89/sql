@save_sqlplus_settings
set lines 119 pages  80 feed on
column logpriv format a21 head "Owner/ProgOwn"
column job_name format A25 head "JobName"
column fail format a9 head "F/Ena/Sid"
col what for a23 head 'What'
select 
a.job_name 
,substr(a.program_name,instr(a.program_name,':='),23) What
,to_char(a.last_start_date,'dd/mm HH24:MI') "Last"
,to_char(a.next_run_date,'dd/mm HH24:MI') "Next"
,to_char(nvl(a.failure_count,0))||'/'||substr(a.enabled,1)||'/'||to_char(nvl(b.session_id,0)) as fail
,substr(a.owner,1,10)||'/'||substr(a.program_owner,1,10) as logpriv
from dba_scheduler_jobs a,
dba_scheduler_running_jobs b
where b.owner(+)=a.owner and b.job_name(+)=a.job_name
order by
next_run_date desc;
@restore_sqlplus_settings
