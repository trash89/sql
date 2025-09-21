--
--  Script    : lsqlid.sql
--  Purpose   : obtain the sql statement FROM v$sqlarea based on SQL ID, spool in target.sql file
--  Tested on : 10g,11g,12c,19c,23c
--
@save_sqp_set

set head off autoprint off echo off show off tab off termout on newp none feed off lines 4096 long 5000000
undef un_id
accept un_id char prompt 'SQL ID : '
col sql_fulltext for a2048
spool target.sql
SELECT
      sql_fulltext||';' AS sql_fulltext
FROM
      gv$sqlarea b
WHERE
      b.sql_id='&un_id'
      AND sys_context('USERENV','CON_ID')=b.con_id    
      AND b.inst_id=to_number(sys_context('USERENV','INSTANCE'))  
;
spool off
undef un_id

@rest_sqp_set
