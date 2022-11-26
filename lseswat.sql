col event format A30
col p2 format 999999
col seconds_in_wait format 999
set line 1000
select sid,seq#, event, p1,p2,seconds_in_wait as "Wait"
 from v$session_wait
where event not like '%Net%'
and event not like '%ipc mess%' 
and event not like '%mon timer%'
and event not like 'pipe get%'
and event not like 'wakeup time manager%'
and event not like 'unread message%'
;
