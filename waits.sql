--
--   Script  : waits.sql
--   Author  : Marius RAICU
--   Purpose : Show some of the system statistics(GV$SYSSTAT), waits statistics(GV$SYSTEM_EVENT), file statistics(GV$FILESTAT+GV$TEMPSTAT)
--             from the startup of the instance.This script is Parallel Server aware.
--
--   For     : Oracle 8i,9i
--   Required: TIMED_STATISTICS=TRUE in INIT.ORA
--
@save_sqlplus_settings

set term off
column inst noprint new_value inst
select 'waits_'||i.instance_name||'_'||i.host_name||'_'||to_char(sysdate,'dd_mm_rrrr_hh24_mi')||'.lst' as inst from v$instance i
where i.instance_number=userenv('instance');

col val1 new_val tot_time_waited noprint
col val2 new_val tot_total_waits noprint

select		sum(time_waited) val1,
		sum(total_waits) val2
from		v$system_event a
where
       a.event not like 'SQL%'
  and  a.event not like 'KXFX%'
  and  a.event not like '%slave wait'
  and  a.event not like 'Wait for slaves%'
  and  a.event not like 'Parallel%Qu%Idle%Sla%'
  and  a.event not like 'refresh controfile%'
  and  a.event not in (
'reliable message',
'file identify',
'file open',
'dispatcher timer',
'virtual circuit status',
'control file parallel write',
'control file sequential read',
'refresh controlfile command',
'Null event',
'null event',
'pmon timer',
'rdbms ipc reply',
'rdbms ipc message',
'reliable message',
'smon timer',
'wakeup time manager',
'PX Idle Wait',
'SQL*Net message to client',
'SQL*Net message from client',
'SQL*Net break/reset to client');

set term on
set lines 130 pages 200 feed off newp none trims on trim off
col time_waited     for 99999999      heading 'Time|Waited(CSec)'
col time_waited_min for 99999.99      head 'TimeW|(Min)'
col time_pct        for 990.00        head "% Time|Waited"
col cnt_pct         for 990.00        head "% Waits"
col average_wait    for 99999999      head 'Average|Wait(CSec)'
col event           for a56           head 'Event Name'
col diff_timeM      for 99999999.99   head 'Diff Time(Min)'
col diff_timeS      for 99999999.99   head 'Diff Time(CSec)'
col sid             for 999999
col seq#            for 999999
col seconds_in_wait for 9999999       head 'Seconds|in wait'
col statistic       for a58 justify c head 'Statistic'
col statvalue       for 99,999,999,999,999,999,990 justify c heading 'Value'
col total_waits     for 9999999       head 'Total|Waits'
col total_timeouts  for 9999999       head 'Total|Timeouts'
col inst_id         for 99            head 'I'
break on inst_id skip 1
spool &&inst 
Prompt System statistics (GV$SYSSTAT)
select
    nvl(s.inst_id,1) as inst_id,
    n.name        statistic,
    s.value       statvalue
from
    gv$sysstat     s,
    gv$statname    n
where
    s.inst_id=n.inst_id and s.statistic# = n.statistic# and s.value!=0 and
    (n.name like '%SQL%' or
     n.name like '%enqueue%' or
     n.name like '%redo%' or
     n.name like '%table%' or
     n.name like '%user%' or
     n.name like '%CPU%' or
     n.name like '%sort%' or
     n.name like '%parse%' or
     n.name like 'workarea exec%'
     )
order by 1,2 asc;

prompt System summary perspective (GV$SYSTEM_EVENT)
select nvl(inst_id,1) as inst_id,
       event,
       total_waits,
       total_timeouts,
       100*(total_waits/&tot_total_waits) cnt_pct,
       time_waited,
       round((time_waited/100)/60,2) as time_waited_min,
       100*(time_waited/&tot_time_waited) time_pct,
       average_wait
from gv$system_event 
where time_waited!=0 and
       event not like 'SQL%'
  and  event not like 'KXFX%'
  and  event not like '%slave wait'
  and  event not like 'Wait for slaves%'
  and  event not like 'Parallel%Qu%Idle%Sla%'
  and  event not like 'refresh controfile%'
  and  event not in (
'reliable message',
'file identify',
'file open',
'dispatcher timer',
'virtual circuit status',
'control file parallel write',
'control file sequential read',
'refresh controlfile command',
'Null event',
'null event',
'pmon timer',
'rdbms ipc reply',
'rdbms ipc message',
'reliable message',
'smon timer',
'wakeup time manager',
'PX Idle Wait',
'SQL*Net message to client',
'SQL*Net message from client',
'SQL*Net break/reset to client')
order by nvl(inst_id,1),time_waited;

clear breaks
prompt File statistics (GV$FILESTAT)
col file#    for 999    head 'F#'
col maxiortm for 999999 head 'MaxRtm'
col maxiowtm for 999999 head 'MaxWtm'
select nvl(inst_id,1) as inst_id,file#,phyrds,phyblkrd,readtim,maxiortm,phywrts,phyblkwrt,writetim,maxiowtm from gv$filestat order by nvl(inst_id,1);
prompt Temp File statistics (GV$TEMPSTAT)
select nvl(inst_id,1) as inst_id,file#,phyrds,phyblkrd,readtim,maxiortm,phywrts,phyblkwrt,writetim,maxiowtm from gv$tempstat order by nvl(inst_id,1);


@@f.sql

prompt

col startup_time    for a19
col Current_time    for a19
col instance_number for 99 head 'I'
select instance_number,instance_name, 
       to_char(startup_time,'dd/mm/rrrr hh24:mi:ss') as Startup_Time,
       to_char(sysdate,'dd/mm/rrrr hh24:mi:ss') as Current_Time,
       (sysdate-startup_time)*24*60 as Diff_TimeM, 
       (sysdate-startup_time)*24*60*60*100 as Diff_TimeS 
from gv$instance;
clear columns
clear breaks
set lines 150 pages 22 feed on head on

spool off

@restore_sqlplus_settings
ed &&inst
