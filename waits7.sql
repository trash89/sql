set term off
column inst noprint new_value inst
select 'waits_'||ltrim(rtrim(substr(t.instance,1,4)))||'_'||ltrim(rtrim(p.terminal))||'_'||to_char(sysdate,'dd_mm_rrrr_hh24_mi')||'.lst' as inst from v$thread t,v$process p where p.pid=2;
set term on
set lines 110 pages 80 feed off newp none trims on trim off
column time_waited  format 99999999 heading 'Time|Waited(CSec)'
column time_waited_min format 99999.99 head 'Time|Waited(Min)'
column average_wait format 99999999 heading 'Average|Wait(CSec)'
column event format a40 heading 'Event Name'
column diff_timeM format 99999999.99 heading 'Diff Time(Min)'
column diff_timeS format 99999999.99 heading 'Diff Time(CSec)'
column sid format 999999
column seq# format 999999
column seconds_in_wait format 9999999 heading 'Seconds|in wait'
col statistic  format a58 justify c heading 'Statistic'
col statvalue  format 99,999,999,999,999,999,990 justify c heading 'Value'
column total_waits heading 'Total|Waits'
column total_timeouts heading 'Total|Timeouts'
spool &&inst 
Prompt System statistics (V$SYSSTAT)
select
    n.name        statistic,
    s.value       statvalue
from
    v$statname    n,
    v$sysstat     s
where
    n.statistic# = s.statistic# and s.value!=0 and
    (n.name like '%SQL%' or
     n.name like '%enqueue%' or
     n.name like '%redo%' or
     n.name like '%table%' or
     n.name like '%user%' or
     n.name like '%CPU%' or
     n.name like '%sort%'
     )
order by 1 asc;

prompt System summary perspective (V$SYSTEM_EVENT)
select event,
       total_waits,
       total_timeouts,
       time_waited,
       round((time_waited/100)/60,2) as time_waited_min,
       average_wait
from v$system_event 
where time_waited!=0 and
      event not like 'SQL*Net%' and
      event not like '%ipc%' and
      event not like '%timer%' and
      event not like '%message%' and
      event not like '%pipe get%' and
      event not like '%wakeup%' and
      event not like '%Null%'   
order by time_waited;
prompt File statistics (V$FILESTAT)
set lines 90
column file# format 999 head 'F#'
column maxiortm format 999999 head 'MaxRtm'
column maxiowtm format 999999 head 'MaxWtm'
select file#,phyrds,phyblkrd,readtim,phywrts,phyblkwrt,writetim from v$filestat;

column startup_time format a19
column Current_time format a19
select instance, 
       to_char(logon_time,'dd/mm/rrrr hh24:mi:ss') as Startup_Time,
       to_char(sysdate,'dd/mm/rrrr hh24:mi:ss') as Current_Time,
       (sysdate-logon_time)*24*60 as Diff_TimeM, 
       (sysdate-logon_time)*24*60*60*100 as Diff_TimeS 
from v$session,dual,v$thread where sid=1;
clear columns
set lines 150 pages 22 feed on head on
spool off
