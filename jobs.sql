@save_sqlplus_settings

set lines 200 pages 80 feed on

column logpriv format a30 head "LogUser/PrivUser"
column job format 99999999 head "Job#"
column fail format a8 head "F/B/Sid"
col what for a80 head 'What'

select 
  a.job,
  substr(a.what,instr(a.what,':='),80) as What,
  to_char(a.last_date,'dd/mm HH24:MI') as "Last",
  to_char(a.next_date,'dd/mm HH24:MI') as "Next",
  to_char(nvl(a.failures,0))||'/'||a.broken||'/'||to_char(nvl(b.sid,0)) as fail,
  a.log_user||'/'||a.priv_user as logpriv
from 
  dba_jobs a,dba_jobs_running b
where 
  b.job(+)=a.job
order by 
  next_date desc;

@restore_sqlplus_settings
