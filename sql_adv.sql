--
--  Script    : sql_adv.sql
--  Purpose   : launch an SQL Access advisor to recommend new indexes
--  Tested on : 11g,12c,19c
--
@save_sqp_set

set lines 250 pages 50
DECLARE
  taskname         VARCHAR2(30):='SQLACCESS_marius';
  task_desc        VARCHAR2(256):='SQL Access Advisor';
  task_or_template VARCHAR2(30):='SQLACCESS_EMTASK';
  task_id          NUMBER:=0;
  num_found        NUMBER;
  sts_name         VARCHAR2(256):='SQLACCESS_marius_sts';
  sts_cursor       dbms_sqltune.sqlset_cursor;
BEGIN
  BEGIN
    dbms_advisor.delete_task(taskname);
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;
  BEGIN
    dbms_sqltune.drop_sqlset(sts_name);
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;
 /* Create Task */
  dbms_advisor.create_task(dbms_advisor.sqlaccess_advisor,task_id,taskname,task_desc,task_or_template);
 /* Reset Task */
  BEGIN
    dbms_advisor.reset_task(taskname);
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;
 /* Delete Previous STS Workload Task Link */
  SELECT
    count(*) into num_found FROM user_advisor_sqla_wk_map
  WHERE
    task_name=taskname
    AND workload_name=sts_name;
  IF num_found>0 THEN
    dbms_advisor.delete_sqlwkld_ref(taskname,sts_name,1);
  END IF;
 /* Delete Previous STS */
  SELECT
    count(*)into num_found FROM user_advisor_sqlw_sum WHERE workload_name=sts_name;
  IF num_found>0 THEN
    dbms_sqltune.delete_sqlset(sts_name);
  END IF;
 /* Create STS */
  dbms_sqltune.create_sqlset(sts_name,'Obtain workload FROM cursor cache');
 /* Select all statements in the cursor cache. */
  OPEN sts_cursor FOR
    SELECT value(p) FROM TABLE(dbms_sqltune.SELECT_cursor_cache('parsing_schema_name not in ( ''SYS'',''SYSTEM'',''DBSNMP'')')) p;
 /* Load the statements into STS. */
  dbms_sqltune.load_sqlset(sts_name,sts_cursor);
  CLOSE sts_cursor;
 /* Link STS Workload to Task */
  dbms_advisor.add_sqlwkld_ref(taskname,sts_name,1);
 /* Set STS Workload Parameters */
  dbms_advisor.set_task_parameter(taskname,'VALID_ACTION_LIST',dbms_advisor.advisor_unused);
  dbms_advisor.set_task_parameter(taskname,'VALID_MODULE_LIST',dbms_advisor.advisor_unused);
 /* 25 SQL Statements */
  dbms_advisor.set_task_parameter(taskname,'SQL_LIMIT','25');  -- 25 statements
  dbms_advisor.set_task_parameter(taskname,'VALID_USERNAME_LIST',dbms_advisor.advisor_unused);
  dbms_advisor.set_task_parameter(taskname,'VALID_TABLE_LIST',dbms_advisor.advisor_unused);
  dbms_advisor.set_task_parameter(taskname,'INVALID_TABLE_LIST',dbms_advisor.advisor_unused);
  dbms_advisor.set_task_parameter(taskname,'INVALID_ACTION_LIST',dbms_advisor.advisor_unused);
  dbms_advisor.set_task_parameter(taskname,'INVALID_USERNAME_LIST',dbms_advisor.advisor_unused);
  dbms_advisor.set_task_parameter(taskname,'INVALID_MODULE_LIST',dbms_advisor.advisor_unused);
  dbms_advisor.set_task_parameter(taskname,'VALID_SQLSTRING_LIST',dbms_advisor.advisor_unused);
  dbms_advisor.set_task_parameter(taskname,'INVALID_SQLSTRING_LIST','"@!"');
 /* Set Task Parameters */
 /* Only Index Recommandations, possible combinations
      INDEX
      MVIEW
      INDEX, PARTITION
      INDEX, MVIEW, PARTITION
      INDEX, TABLE, PARTITION
      MVIEW, PARTITION
      MIVEW, TABLE, PARTITION
      INDEX, MVIEW, TABLE, PARTITION
      TABLE, PARTITION
      EVALUATION
 */
  dbms_advisor.set_task_parameter(taskname,'ANALYSIS_SCOPE','INDEX');
  dbms_advisor.set_task_parameter(taskname,'CREATION_COST','TRUE');
  dbms_advisor.set_task_parameter(taskname,'DAYS_TO_EXPIRE','7');
  dbms_advisor.set_task_parameter(taskname,'DEF_INDEX_OWNER',dbms_advisor.advisor_unused);
  dbms_advisor.set_task_parameter(taskname,'DEF_INDEX_TABLESPACE',dbms_advisor.advisor_unused);
 /*  
  dbms_advisor.set_task_parameter(taskname,'DEF_MVIEW_OWNER',dbms_advisor.advisor_unused);
  dbms_advisor.set_task_parameter(taskname,'DEF_MVIEW_TABLESPACE',dbms_advisor.advisor_unused);
  dbms_advisor.set_task_parameter(taskname,'DEF_MVLOG_TABLESPACE',dbms_advisor.advisor_unused);
  dbms_advisor.set_task_parameter(taskname,'DEF_PARTITION_TABLESPACE',dbms_advisor.advisor_unused);
 */
  dbms_advisor.set_task_parameter(taskname,'DML_VOLATILITY','TRUE');
  dbms_advisor.set_task_parameter(taskname,'JOURNALING','4');
  dbms_advisor.set_task_parameter(taskname,'MODE','COMPREHENSIVE');
  dbms_advisor.set_task_parameter(taskname,'RANKING_MEASURE','PRIORITY,OPTIMIZER_COST');
  dbms_advisor.set_task_parameter(taskname,'STORAGE_CHANGE',dbms_advisor.advisor_unlimited);
 /* 10 min, default is 720 (12h) */
  dbms_advisor.set_task_parameter(taskname,'TIME_LIMIT',10); -- 10 min
  dbms_advisor.set_task_parameter(taskname,'WORKLOAD_SCOPE','FULL');
 /* Execute Task */
  dbms_advisor.execute_task(taskname);
END;
/
-- Display the resulting script.
set lines 4096 long 5000000 pages 50
col script for a2048
spool /tmp/SQLACCESS_marius.sql
SELECT
  dbms_advisor.get_task_script('SQLACCESS_marius')as script
FROM
  dual
;
spool off

@rest_sqp_set

ed /tmp/SQLACCESS_marius.sql
