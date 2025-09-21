--
--  Script    : alert_log.sql
--  Purpose   : Create the tables ALERT_LOG and DG_LOG, ORGANIZATION EXTERNAL, based on the database's alert.log and DataGuard log
--  Tested on : 11g +
--
@save_sqp_set

DECLARE
  dummy         BINARY_INTEGER;
  bdump         VARCHAR2(200);
  db_name       VARCHAR2(200);
  instance_name VARCHAR2(200);
  dummy2        BINARY_INTEGER;
BEGIN
  dummy2:=dbms_utility.get_parameter_value('diagnostic_dest',dummy,bdump);
  dummy2:=dbms_utility.get_parameter_value('db_name',dummy,db_name);
  dummy2:=dbms_utility.get_parameter_value('instance_name',dummy,instance_name);
  EXECUTE IMMEDIATE 'create or replace directory bdump as '||chr(39)||bdump||'/diag/rdbms/'||lower(db_name)||'/'||instance_name||'/trace'||chr(39);
  BEGIN
    EXECUTE IMMEDIATE 'drop table alert_log';
    EXECUTE IMMEDIATE 'drop table dg_log';
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
  BEGIN
    EXECUTE IMMEDIATE 'create table alert_log(line varchar2(4000)) organization external (type oracle_loader default directory bdump access parameters (records delimited by newline) location ('||chr(39)||'alert_'||instance_name||'.log'||chr(39)||') ) reject limit unlimited';
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
  BEGIN
    EXECUTE IMMEDIATE 'create table dg_log(line varchar2(4000)) organization external (type oracle_loader default directory bdump access parameters (records delimited by newline) location ('||chr(39)||'drc'||instance_name||'.log'||chr(39)||') ) reject limit unlimited';
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
END;
/
ttitle left 'Table alert_log'
SELECT count(*) as rows_alert_log FROM alert_log;

ttitle left 'Table dg_log'  
SELECT count(*) as rows_dg_log FROM dg_log;

@rest_sqp_set
