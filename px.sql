set lines 200 pages 200 trimspool on 
col program for a25
col sid for 999999
select s.sid,s.status,s.program,w.event,w.p1,w.p2
from v$session s,v$transaction t,v$session_wait w
where s.taddr=t.addr and s.sid=w.sid;