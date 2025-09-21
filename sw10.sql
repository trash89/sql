--
--  Script    : sw10.sql
--  Purpose   : show session waits
--  Tested on : 8,8i,9i,10g,11g
--
@save_sqp_set

set lines 120 pages 50 feed on newp none trims on trim off
col wait_time       for 9,999,999,999  head 'Time|Waited(CSec)'
col event           for a40         head 'Event Name'
col sid             for 999999
col seconds_in_wait for 999,999,999   head 'Seconds|in wait'
ttitle left 'Session wait statistics(V$SESSION_WAIT)'
SELECT
    sw.sid
   ,sw.event
   ,sw.p1
   ,sw.p2
   ,sw.p3
   ,sw.wait_time
   ,sw.seconds_in_wait
FROM
    gv$session_wait sw
WHERE
    wait_time!=0
    AND sw.inst_id=to_number(sys_context('USERENV','INSTANCE'))
 --,AND event not like 'SQL*Net%'
    --,AND event not like '%ipc%'
    --,AND event not like '%timer%'
    --,AND event not like '%message%'
    --,AND event not like '%pipe get%'
    --,AND event not like '%wakeup%'
    --,AND event not like '%Null%'
ORDER BY
    wait_time
;

@rest_sqp_set
