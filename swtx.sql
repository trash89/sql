--
--  Script    : swtx.sql
--  Purpose   : show sessions waiting in transactions
--  Tested on : 12c+, for versions <12c, sx10.sql or comment out -- AND sys_context('USERENV','CON_ID')=...
--
@save_sqp_set

set lines 200 pages 50 

col sidser      for a15 head 'Sid,S#'
col sql_id      for a13
col event       for a57
col sid         for 999999
col username    for a30 head 'Oracle User'
col os          for a50 head 'OSUser@machine'
ttitle left 'v$session_wait, v$transaction, v$session'
SELECT
    to_char(s.sid)||','||to_char(s.serial#)     AS sidser
   ,s.sql_id
   ,s.status
   ,w.event
   ,w.p1
   ,w.p2
   ,s.username
   ,substr(trim(s.osuser)||'@'||trim(s.machine),1,50) as os
FROM
    gv$session      s
   ,gv$transaction  t
   ,gv$session_wait w
WHERE
    s.inst_id=t.inst_id
    AND s.inst_id=to_number(sys_context('USERENV','INSTANCE'))
    AND s.inst_id=w.inst_id
    AND s.taddr=t.addr
    AND sys_context('USERENV','CON_ID')=s.con_id
    AND s.con_id=t.con_id
    AND s.con_id=w.con_id    
    AND s.sid=w.sid
ORDER BY
    status DESC
;

@rest_sqp_set
