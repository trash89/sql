---
---  Create the ALERT_LOG table, ORGANIZATION EXTERNAL, based on the database's alert.log 
---  only for 9i+
---
declare
 dummy binary_integer;
 bdump varchar2(200);
 db_name varchar2(200);
 dummy2 binary_integer;
begin
  dummy2:=dbms_utility.get_parameter_value('background_dump_dest',dummy,bdump); 
  dummy2:=dbms_utility.get_parameter_value('db_name',dummy,db_name); 
  execute immediate 'create or replace directory bdump as '||chr(39)||bdump||'/'||chr(39);
  begin
    execute immediate 'drop table alert_log';
  exception
  when others then null;
  end;
  execute immediate 'create table alert_log(line varchar2(4000)) organization external (type oracle_loader default directory bdump access parameters (records delimited by newline) location ('||chr(39)||'alert_'||db_name||'.log'||chr(39)||') ) reject limit unlimited';
end;
/
select count(*) from alert_log;

