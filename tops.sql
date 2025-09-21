--
--  Script    : tops.sql
--  Purpose   : Show top 10 sessions by logical reads, exec count or CPU (after a script FROM Tim Hall)
--  Tested on : 9i,10g,11g,12c,19c, for versions <12c, comment out -- and sys_context('USERENV','CON_ID')=...
--
@save_sqp_set

set lines 171 pages 50
set feed off

col sidser           for a14              head 'sid,serial#'
col Logon            for a11
col sql_id           for a13
col min              for a10               head 'MinLCall'
col status           for a8               head 'Status'
col usterm           for a90              head 'OrclUser -> OSUser@machine by program'

col value            for 9,999,999,999,999    head 'sessLogiReads'
ttitle left 'Session Logical Reads'
SELECT * FROM (
SELECT 
       to_char(a.sid)||','||to_char(a.serial#)  as sidser
      ,to_char(a.logon_time,'dd/mm HH24:MI')    as logon
      ,a.sql_id
      ,a.status
      ,c.value
      ,to_char((last_call_et/60),'99,999.99')  as min
      ,trim(nvl(a.username,'SYS'))||' -> '||substr(trim(a.osuser)||'@'||trim(a.machine),1,30)||' by '||substr(trim(replace(a.program,'TNS V1-V3','TNS')),(-1)*least(40,length(trim(replace(a.program,'TNS V1-V3','TNS'))))) as usterm      
FROM   gv$session a,
       gv$sesstat c,
       gv$statname d
WHERE
    a.inst_id=c.inst_id
    AND a.inst_id=to_number(sys_context('USERENV','INSTANCE'))
    AND a.inst_id=d.inst_id
    AND a.sid=c.sid
    AND c.statistic#=d.statistic#
    AND c.value!=0
    AND d.name ='session logical reads'
    AND sys_context('USERENV','CON_ID')=a.con_id
    AND a.con_id=c.con_id
    AND a.con_id=d.con_id
ORDER BY 
    c.value DESC
)
    WHERE
        rownum<11
;

col value            for 9,999,999,999,999    head 'exec count'
ttitle left 'Execute count'
SELECT * FROM (
SELECT 
       to_char(a.sid)||','||to_char(a.serial#)  as sidser
      ,to_char(a.logon_time,'dd/mm HH24:MI')    as logon
      ,a.sql_id
      ,a.status
      ,c.value
      ,to_char((last_call_et/60),'99,999.99')  as min
      ,trim(nvl(a.username,'SYS'))||' -> '||substr(trim(a.osuser)||'@'||trim(a.machine),1,30)||' by '||substr(trim(replace(a.program,'TNS V1-V3','TNS')),(-1)*least(40,length(trim(replace(a.program,'TNS V1-V3','TNS'))))) as usterm      
FROM   gv$session a,
       gv$sesstat c,
       gv$statname d
WHERE
    a.inst_id=c.inst_id
    AND a.inst_id=to_number(sys_context('USERENV','INSTANCE'))
    AND a.inst_id=d.inst_id
    AND a.sid=c.sid
    AND c.statistic#=d.statistic#
    AND c.value!=0
    AND d.name = 'execute count'
    AND sys_context('USERENV','CON_ID')=a.con_id
    AND a.con_id=c.con_id
    AND a.con_id=d.con_id
ORDER BY 
    c.value DESC
)
    WHERE
        rownum<11
;

col value            for 9,999,999,999,999    head 'CPU used'
ttitle left 'CPU used'
SELECT * FROM (
SELECT 
       to_char(a.sid)||','||to_char(a.serial#)  as sidser
      ,to_char(a.logon_time,'dd/mm HH24:MI')    as logon
      ,a.sql_id
      ,a.status
      ,c.value
      ,to_char((last_call_et/60),'99,999.99')  as min
      ,trim(nvl(a.username,'SYS'))||' -> '||substr(trim(a.osuser)||'@'||trim(a.machine),1,30)||' by '||substr(trim(replace(a.program,'TNS V1-V3','TNS')),(-1)*least(40,length(trim(replace(a.program,'TNS V1-V3','TNS'))))) as usterm      
FROM   gv$session a,
       gv$sesstat c,
       gv$statname d
WHERE  
    a.inst_id=c.inst_id
    AND a.inst_id=to_number(sys_context('USERENV','INSTANCE'))
    AND a.inst_id=d.inst_id
    AND a.sid=c.sid
    AND c.statistic#=d.statistic#
    AND c.value!=0
    AND d.name = 'CPU used by this session'
    AND sys_context('USERENV','CON_ID')=a.con_id
    AND a.con_id=c.con_id
    AND a.con_id=d.con_id
ORDER BY 
    c.value DESC
)
    WHERE
        rownum<11
;

@rest_sqp_set
