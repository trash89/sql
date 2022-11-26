purge recyclebin;

declare
begin
  for rec in (select trigger_name from user_triggers) loop
    execute immediate 'alter trigger '||rec.trigger_name||' disable';
  end loop;
end;
/
select status,count(*) from user_triggers group by status;



set serveroutput on size unlimited
declare
begin
  for rec in (select constraint_type,table_name,constraint_name from user_constraints where constraint_type in ('C','R') and status='ENABLED' order by 1,3) loop
    begin
       execute immediate 'alter table '||rec.table_name||' disable constraint '||rec.constraint_name;
    exception
      when others then dbms_output.put_line(rec.table_name||' '||rec.constraint_name||' '||sqlerrm);
    end;
  end loop;

  for rec in (select constraint_type,table_name,constraint_name from user_constraints where constraint_type in ('P','U') and status='ENABLED' order by 1,3) loop
    begin  
       execute immediate 'alter table '||rec.table_name||' disable constraint '||rec.constraint_name;
    exception
      when others then dbms_output.put_line(rec.table_name||' '||rec.constraint_name||' '||sqlerrm);
    end;
  end loop;
end;
/

select constraint_type,status,count(*) from user_constraints group by constraint_type,status;

begin
  for rec in (select object_name,policy_name from user_policies) loop
    dbms_rls.enable_policy(object_name=>rec.object_name,policy_name=>rec.policy_name,enable=>false);
  end loop;
end;
/

select enable,count(*) from user_policies group by enable;

set serveroutput on size unlimited
declare
begin
  for rec in (select table_name from user_tables where table_name not in ('CREATE$JAVA$LOB$TABLE') and table_name not like 'WB_RT%' and table_name not in (select mview_name from user_mviews)) loop
    begin  
        execute immediate 'truncate table '||rec.table_name;
    exception
    when others then
      begin
        dbms_output.put_line(rec.table_name||' '||sqlerrm);
      end;
    end;
  end loop;
end;
/


/*
declare
begin
  for rec in (select table_name from user_tables where table_name not in (select mview_name from user_mviews)) loop
    execute immediate 'drop table '||rec.table_name||' cascade constraints';
  end loop;
  for rec in (select object_name,object_type from user_objects where object_type in ('FUNCTION','PACKAGE','PROCEDURE','SEQUENCE','VIEW','MATERIALIZED VIEW','DATABASE LINK')) loop
     execute immediate 'drop '||rec.object_type||' '||rec.object_name;
  end loop;
end;
/
select object_type,count(*) from user_objects group by object_type;
*/





rem on import les donnees par database link en faisant insert ... select * from table_xxx@l1
spool \tmp\ins.lst

set serveroutput on size unlimited
declare
  v_err varchar2(4000):=null;
begin
  for rec in (select table_name from user_tables where table_name not in ('CREATE$JAVA$LOB$TABLE') and table_name not like 'WB_RT%' and table_name not in (select mview_name from user_mviews)) loop
      begin
        execute immediate 'insert /*+ APPEND */ into '||rec.table_name||' select * from '||rec.table_name||'@prod';
--        execute immediate 'insert into '||rec.table_name||' select * from '||rec.table_name||'@prd';
        commit;
      exception
        when others then
          begin
            v_err:=sqlerrm;
            dbms_output.put_line(rec.table_name||' '||v_err);
          end;
      end;
  end loop;
  commit;
end;
/

rem insert into hab_users select USID,USNAME,USMAIL,USDISABLE,USCREA_USID,USPWD from hab_users@hser;
rem  insert into tbl_calendar select ID,PERIOD_KEY,RPT_YEAR,RPT_QUARTER,RPT_MONTH from tbl_calendar@hser;
spool off





@?/rdbms/admin/utlexcpt

set serveroutput on size unlimited
declare
begin
  for rec in (select constraint_type,table_name,constraint_name from user_constraints where constraint_type in ('P','U') and (status!='ENABLED' or VALIDATED!='VALIDATED') order by 1,3) loop
    begin  
       execute immediate 'alter table '||rec.table_name||' enable novalidate constraint '||rec.constraint_name;
    exception
      when others then dbms_output.put_line(rec.table_name||' '||rec.constraint_name||' '||sqlerrm);
    end;
    begin  
       execute immediate 'alter table '||rec.table_name||' enable constraint '||rec.constraint_name;
    exception
      when others then dbms_output.put_line(rec.table_name||' '||rec.constraint_name||' '||sqlerrm);
    end;
  end loop;
  for rec in (select constraint_type,table_name,constraint_name from user_constraints where constraint_type in ('C','R') and (status!='ENABLED' or VALIDATED!='VALIDATED') order by 1,3) loop
    begin
       execute immediate 'alter table '||rec.table_name||' enable novalidate constraint '||rec.constraint_name;
    exception
      when others then dbms_output.put_line(rec.table_name||' '||rec.constraint_name||' '||sqlerrm);
    end;
    begin
       execute immediate 'alter table '||rec.table_name||' enable constraint '||rec.constraint_name;
    exception
      when others then dbms_output.put_line(rec.table_name||' '||rec.constraint_name||' '||sqlerrm);
    end;
  end loop;
end;
/

select constraint_type,status,validated,count(*) from user_constraints where (status!='ENABLED') or (validated!='VALIDATED') group by constraint_type,status,validated order by 1,2,3;
select distinct table_name,compression from user_tab_partitions where compression!='DISABLED';
select table_name,constraint_name from user_constraints where r_constraint_name in (select constraint_name from user_constraints where table_name='INC_SO_REQ_LINE_ITEM_ESH');


declare
begin
  for rec in (select trigger_name from user_triggers) loop
    execute immediate 'alter trigger '||rec.trigger_name||' enable';
  end loop;
end;
/
select status,count(*) from user_triggers group by status;

begin
  for rec in (select object_name,policy_name from user_policies) loop
    dbms_rls.enable_policy(object_name=>rec.object_name,policy_name=>rec.policy_name,enable=>true);
  end loop;
end;
/

select enable,count(*) from user_policies group by enable;

