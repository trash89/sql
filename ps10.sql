--
--  Script    : ps10.sql
--  Purpose   : show bg processes and their associated trace files
--  Tested on : 10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 100 pages 50
col pid             for 99999999
col description     for a49
col program         for a40
ttitle left 'v$process, v$bgprocess'
SELECT
    p.pid
   ,bgp.description
   ,substr(trim(replace(p.program,'TNS V1-V3','TNS')),(-1)*least(40,length(trim(replace(p.program,'TNS V1-V3','TNS')))))   as program   
FROM
    gv$process   p
   ,gv$bgprocess bgp
WHERE
    p.inst_id=bgp.inst_id
    AND p.inst_id=to_number(sys_context('USERENV','INSTANCE'))  
    AND p.addr=bgp.paddr(+)
ORDER BY
    p.pid
;

@rest_sqp_set
