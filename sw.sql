set term off
column inst noprint new_value inst
select 'sw_'||instance||'_'||host_name||'_'||to_char(sysdate,'dd_mm_rrrr_hh24_mi')||'.lst' as inst from v$thread,v$instance;
set term on
set lines 110 pages 80 feed off newp none trims on trim off
column wait_time  format 99999999 heading 'Time|Waited(CSec)'
column event format a40 heading 'Event Name'
column sid format 999999
column seconds_in_wait format 9999999 heading 'Seconds|in wait'
--spool &&inst 
Prompt Session wait statistics (V$SESSION_WAIT)
select sid,event,p1,p2,p3,wait_time,seconds_in_wait from v$session_wait
where wait_time!=0
--      event not like 'SQL*Net%' and
--      event not like '%ipc%' and
--      event not like '%timer%' and
--      event not like '%message%' and
--      event not like '%pipe get%' and
--      event not like '%wakeup%' and
--      event not like '%Null%'   
order by wait_time;
clear columns
set lines 150 pages 22 feed on head on
--spool off

