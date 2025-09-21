--
--  Script    : sql_tune.sql
--  Purpose   : tune a SQL statement identified by SQL ID using dbms_sqltune
--  Tested on : 11g,12c,19c
--
@save_sqp_set

set lines 190 pages 50
undef sql_id
accept sql_id char prompt 'SQL ID ?    : ' default ''
DECLARE
  l_task_id   VARCHAR2(20);
  mytask_name VARCHAR2(15):='SQLTune_marius';
BEGIN
  BEGIN
    dbms_advisor.delete_task(mytask_name);
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;
  BEGIN
    dbms_sqltune.drop_tuning_task(mytask_name);
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;
  l_task_id := dbms_sqltune.create_tuning_task(
    sql_id => '&&sql_id',
    scope => 'COMPREHENSIVE',
    time_limit => 300, -- in seconds, 5 min
    task_name => mytask_name);
  dbms_sqltune.execute_tuning_task(mytask_name);
END;
/
undef sql_id
set lines 4096 long 5000000 pages 50
set serveroutput on size 999999
col script for a2048
spool /tmp/SQLTune_marius.sql
SELECT
  dbms_sqltune.report_tuning_task(
    task_name=>'SQLTune_marius'
  ) AS script
FROM
  dual
;

@rest_sqp_set

ed /tmp/SQLTune_marius.sql