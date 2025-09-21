--
--  Script    : alert_log10.sql
--  Purpose   : Create the ALERT_LOG table, ORGANIZATION EXTERNAL, based on the database's alert.log
--  Tested on : 8,8i,9i,10g
--
@save_sqp_set

DECLARE
  dummy   BINARY_INTEGER;
  bdump   VARCHAR2(200);
  db_name VARCHAR2(200);
  dummy2  BINARY_INTEGER;
BEGIN
  dummy2:=dbms_utility.get_parameter_value('background_dump_dest',dummy,bdump);
  dummy2:=dbms_utility.get_parameter_value('db_name',dummy,db_name);
  EXECUTE IMMEDIATE 'create or replace directory bdump as '||chr(39)||bdump||'/'||chr(39);
  BEGIN
    EXECUTE IMMEDIATE 'drop table alert_log';
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
  EXECUTE IMMEDIATE 'create table alert_log(line varchar2(4000)) organization external (type oracle_loader default directory bdump access parameters (records delimited by newline) location ('||chr(39)||'alert_'||db_name||'.log'||chr(39)||') ) reject limit unlimited';
END;
/

SELECT count(*) FROM alert_log;

@rest_sqp_set
