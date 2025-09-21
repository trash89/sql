--
--  Script    : xpl.sql
--  Purpose   : show the plan table for an SQL ID
--  Tested on : 10g,11g,12c,19c,23c
--
@save_sqp_set

undef sql_id
accept sql_id char prompt 'SQL ID ? : ' default ''
set lines 4096 long 5000000 pages 50
col plan_table_output for a4000

SELECT 
    * 
FROM 
    TABLE(dbms_xplan.display_cursor('&&sql_id',0,'TYPICAL allstats'))
;

@rest_sqp_set
