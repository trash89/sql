drop table temp_fk;
create table temp_fk(fk varchar2(4000),err varchar2(4000));

set serveroutput on size 50000 trimout on trimspool on
declare
  string2 varchar2(32565):=null;
  outlist2 varchar2(32565):=null;
  v1_lname_array dbms_utility.lname_array;
  i pls_integer:=0;
  err varchar2(4000):=null;
begin
  for rec in (select * from user_constraints where constraint_type='R'  and table_name not like 'INC_FT%' order by table_name,constraint_name) loop
      for rec1 in (select table_name,constraint_name from user_constraints where constraint_name=rec.r_constraint_name order by 1) loop
        string2:=null;
        i:=1;
        for rec3 in (select table_name,constraint_name from user_constraints where constraint_name=rec.constraint_name) loop
          v1_lname_array.delete;
          i:=1;
          for rec4 in (select column_name from user_cons_columns where table_name=rec3.table_name and constraint_name=rec3.constraint_name order by position) loop
            v1_lname_array(i):=rec4.column_name;
            i:=i+1;
          end loop;
        end loop;
        dbms_utility.table_to_comma(v1_lname_array,i,outlist2);
        string2:='create index '||rec.constraint_name||'_fki'||' on '||rec.table_name||'('||outlist2||') nologging parallel';
        begin
          dbms_output.put_line(string2);
          execute immediate string2;
        exception
          when others then
            begin
              err:=sqlerrm;
              insert into temp_fk values(string2,err);
              commit;
              dbms_output.put_line(string2);
            end;
        end;
      end loop;
    end loop;
end;
/
set lines 200 pages 200 
select * from temp_fk;
drop table temp_fk;
