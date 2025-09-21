--
--  Script    : txs.sql
--  Purpose   : show the transactions per second in db
--  Tested on : 10g,11g,12c,19c
--
@save_sqp_set

set lines 30 pages 50 
ttitle left 'v$sysstat'
SELECT
    s.value/((sysdate-i.startup_time)*86400) as tx_per_sec
FROM
    gv$sysstat  s
   ,gv$instance i
WHERE
    s.inst_id=i.inst_id
    AND s.inst_id=to_number(sys_context('USERENV','INSTANCE'))
    AND s.name='user calls'
;

@rest_sqp_set
