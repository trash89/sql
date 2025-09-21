--
--  Script    : lsql.sql
--  Purpose   : extract running sql text FROM a session id into target.sql file (to be used by explain)
--  Tested on : 8i+ , for versions <12c, comment out and a.con_id=b.con_id and sys_context('USERENV','CON_ID')=a.con_id
--
@save_sqp_set

set head off autoprint off echo off show off tab off termout on newp none feed off lines 4096 long 5000000
undef un_sid
accept un_sid number prompt 'Enter Session ID : '
col sql_fulltext for a2048
spool target.sql
SELECT
      sql_fulltext||';' AS sql_fulltext
FROM
      gv$session a
     ,gv$sqlarea b
WHERE
      a.inst_id=b.inst_id
      AND a.inst_id=to_number(sys_context('USERENV','INSTANCE'))
      AND a.sql_address=b.address
      AND a.sql_hash_value=b.hash_value
      AND a.sid=&un_sid
      AND a.con_id=b.con_id
      AND sys_context('USERENV','CON_ID')=a.con_id
ORDER BY
      b.hash_value
;
spool off
undef un_sid

@rest_sqp_set
