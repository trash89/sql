--
--  Script    : u.sql
--  Purpose   : Show connected users
--  Tested on : 12c,19c
--
@save_sqp_set

set lines 156 pages 50

col sidser           for a14              head 'sid,serial#'
col Logon            for a11
col min              for a11              head 'MinLCall'
col sql_id           for a13
col status           for a8               head 'Status'
col usterm           for a90              head 'OrclUser -> OSUser@machine by program'
col KILL_CMD         for a54
col start_trace      for a65              head 'Trace in session'
col tkproof          for a65
ttitle left 'v$session, v$process'
SELECT
       to_char(a.sid)||','||to_char(a.serial#)  as sidser
      ,to_char(a.logon_time,'dd/mm HH24:MI')    as logon
      ,to_char((a.last_call_et/60),'999,999.99')  as min
      ,a.sql_id      
      ,a.status
      ,trim(nvl(a.username,'SYS'))||' -> '||substr(trim(a.osuser)||'@'||trim(a.machine),1,30)||' by '||substr(trim(replace(a.program,'TNS V1-V3','TNS')),(-1)*least(40,length(trim(replace(a.program,'TNS V1-V3','TNS'))))) as usterm
      --,'exec sys.dbms_system.set_sql_trace_in_session(' ||a.sid||','||a.serial#||',true);' as start_trace
      --,'alter system kill session '''||a.sid||','||a.serial#||',@'||a.inst_id||''' immediate;' KILL_CMD
      --,'tkprof '||(SELECT pap.value FROM gv$diag_info pap WHERE pap.name = 'Diag Trace' AND  pap.inst_id = a.inst_id)||'/'||LOWER(SYS_CONTEXT('userenv','instance_name'))||'_ora_'||b.spid||'.trc'||' /home/oracle/Scripts/trace.txt explain='||a.username||'/Password sort=exeela sys=no' as TKPROOF
FROM
       gv$session a
      ,gv$process b
WHERE
       a.inst_id=b.inst_id
       AND a.inst_id=to_number(sys_context('USERENV','INSTANCE'))
       AND a.paddr=b.addr
       AND a.type!='BACKGROUND'
       AND a.con_id=b.con_id 
       AND sys_context('USERENV','CON_ID')=a.con_id
ORDER BY
       a.status DESC
      ,a.sid
      ,a.logon_time
;

@rest_sqp_set
