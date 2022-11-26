drop table temp_fk;
create table temp_fk(fk varchar2(4000),err varchar2(4000));

set serveroutput on size 50000
declare
  string1 varchar2(32565):=null;
  string2 varchar2(32565):=null;
  outlist1 varchar2(32565):=null;
  outlist2 varchar2(32565):=null;
  v_lname_array dbms_utility.lname_array;
  v1_lname_array dbms_utility.lname_array;
  i pls_integer:=0;
  err varchar2(4000):=null;
begin
  for rec in (select * from user_constraints where constraint_type='R') loop
      for rec1 in (select table_name,constraint_name from user_constraints where constraint_name=rec.r_constraint_name) loop
        string2:=null;
        v_lname_array.delete;
        i:=1;
        for rec2 in (select column_name from user_cons_columns where table_name=rec1.table_name and constraint_name=rec1.constraint_name order by position) loop
          v_lname_array(i):=rec2.column_name;
          i:=i+1;
        end loop;
        for rec3 in (select table_name,constraint_name from user_constraints where constraint_name=rec.constraint_name) loop
          v1_lname_array.delete;
          i:=1;
          for rec4 in (select column_name from user_cons_columns where table_name=rec3.table_name and constraint_name=rec3.constraint_name order by position) loop
            v1_lname_array(i):=rec4.column_name;
            i:=i+1;
          end loop;
        end loop;
        dbms_utility.table_to_comma(v_lname_array,i,outlist1);
        dbms_utility.table_to_comma(v1_lname_array,i,outlist2);
        string2:='alter table '||rec.table_name||' add constraint '||rec.constraint_name||' foreign key('||outlist2||') references '||rec1.table_name||'('||outlist1||') on delete cascade disable';
        string1:='alter table '||rec.table_name||' drop constraint '||rec.constraint_name;
        execute immediate string1;
        begin
          execute immediate string2;
        exception
          when others then
            begin
              err:=sqlerrm;
              insert into temp_fk values(string2,err);
              dbms_output.put_line(string2);
            end;
        end;
      end loop;
    end loop;
end;
/





drop table temp_fk;
create table temp_fk(fk varchar2(4000),err varchar2(4000));

set serveroutput on size 50000
declare
  string1 varchar2(32565):=null;
  string2 varchar2(32565):=null;
  outlist1 varchar2(32565):=null;
  outlist2 varchar2(32565):=null;
  v_lname_array dbms_utility.lname_array;
  v1_lname_array dbms_utility.lname_array;
  i pls_integer:=0;
  err varchar2(4000):=null;
begin
  for rec in (select * from user_constraints where constraint_type='R') loop
      for rec1 in (select table_name,constraint_name from user_constraints where constraint_name=rec.r_constraint_name) loop
        string2:=null;
        v_lname_array.delete;
        i:=1;
        for rec2 in (select column_name from user_cons_columns where table_name=rec1.table_name and constraint_name=rec1.constraint_name order by position) loop
          v_lname_array(i):=rec2.column_name;
          i:=i+1;
        end loop;
        for rec3 in (select table_name,constraint_name from user_constraints where constraint_name=rec.constraint_name) loop
          v1_lname_array.delete;
          i:=1;
          for rec4 in (select column_name from user_cons_columns where table_name=rec3.table_name and constraint_name=rec3.constraint_name order by position) loop
            v1_lname_array(i):=rec4.column_name;
            i:=i+1;
          end loop;
        end loop;
        dbms_utility.table_to_comma(v_lname_array,i,outlist1);
        dbms_utility.table_to_comma(v1_lname_array,i,outlist2);
        string2:='alter table '||rec.table_name||' add constraint '||rec.constraint_name||' foreign key('||outlist2||') references '||rec1.table_name||'('||outlist1||') enable';
        string1:='alter table '||rec.table_name||' drop constraint '||rec.constraint_name;
        execute immediate string1;
        begin
          execute immediate string2;
        exception
          when others then
            begin
              err:=sqlerrm;
              insert into temp_fk values(string2,err);
              dbms_output.put_line(string2);
            end;
        end;
      end loop;
    end loop;
end;
/



