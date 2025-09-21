--
--  Script    : sql_autot.sql
--  Purpose   : launch an SQL Access advisor to recommend new indexes
--  Tested on : 12c
--
@save_sqp_set

BEGIN
  dbms_auto_sqltune.set_auto_tuning_task_parameter(parameter=>'ACCEPT_SQL_PROFILES',value=>'FALSE');
  dbms_auto_sqltune.set_auto_tuning_task_parameter(parameter=>'DAYS_TO_EXPIRE',value=>'7');
  dbms_auto_sqltune.set_auto_tuning_task_parameter(parameter=>'EXECUTION_DAYS_TO_EXPIRE',value=>'7');
  dbms_auto_sqltune.set_auto_tuning_task_parameter(parameter=>'TEST_EXECUTE',value=>'AUTO');
  dbms_auto_sqltune.set_auto_tuning_task_parameter(parameter=>'TIME_LIMIT',value=>'600'); -- 10 min
  dbms_auto_sqltune.set_auto_tuning_task_parameter(parameter=>'SQL_LIMIT',value=>'25'); -- 25 statements
  dbms_auto_sqltune.set_auto_tuning_task_parameter(parameter=>'MODE',value=>'comprehensive');
--  dbms_auto_sqltune.set_auto_tuning_task_parameter(parameter=>'USERNAME',value=>'COCLICO');
END;
/
SET SERVEROUTPUT ON
DECLARE
  l_return VARCHAR2(50);
BEGIN
  l_return:=dbms_auto_sqltune.execute_auto_tuning_task(execution_name=>'marius_auto_sqltune');
  dbms_output.put_line(l_return);
END;
/
set feed on verify off termout on define "&" trims on trim on head on
set head off autoprint off echo off show off tab off termout on newp none feed off lines 4096 long 5000000
set lines 4096 long 5000000 pages 50
col script for a2048
SELECT
  dbms_auto_sqltune.report_auto_tuning_task AS script
FROM
  dual
;

@rest_sqp_set
