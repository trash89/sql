--
--  Script    : bgp.sql
--  Purpose   : Show background processes
--  Tested on : 10g,11g,12c,19c
--
@save_sqp_set

set lines 160 pages 50

col sidser           for a14              head 'sid,serial#'
col Logon            for a11
col min              for 999,999.99       head 'MinLCall'
col sql_id           for a13
col status           for a8               head 'Status'
col pga_used         for 999,999.99       head 'PGAUsed(MB)'
col pga_alloc        for 999,999.99       head 'PGAAlloc(MB)'
col pname            for a5
col description      for a64
break on report
compute sum of pga_used on report
compute sum of pga_alloc on report
ttitle left 'v$process, v$bgprocess, v$session : type = BACKGROUND'
SELECT
       to_char(a.sid)||','||to_char(a.serial#)   as sidser
      ,to_char(a.logon_time,'dd/mm HH24:MI')     as logon
      ,(a.last_call_et/60)                       as min
      ,a.sql_id      
      ,a.status
      ,(b.pga_used_mem/1024/1024)                as pga_used
      ,(b.pga_alloc_mem/1024/1024)               as pga_alloc
      ,b.pname      
      ,bg.description
FROM
       gv$session a
      ,gv$process b
      ,gv$bgprocess bg
WHERE
       a.inst_id=b.inst_id
       AND a.inst_id=to_number(sys_context('USERENV','INSTANCE'))
       AND a.paddr=b.addr
       AND a.type='BACKGROUND'
       AND b.addr=bg.paddr 
       AND b.serial#=bg.pserial#
ORDER BY
      a.sid
;

@rest_sqp_set
