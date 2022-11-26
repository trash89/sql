set serveroutput on size unlimited
declare
  null_array dbms_utility.lname_array;
  const_list dbms_utility.lname_array;
  idx_list dbms_utility.lname_array;
  constraints varchar2(32565):=null;
  idxs varchar2(32565):=null;
  i pls_integer:=null;
  found boolean:=false;
begin
  for rec in (select table_name,constraint_name from user_constraints where constraint_type='R') loop
      i:=null;
      const_list:=null_array;
      select column_name bulk collect into const_list from user_cons_columns where table_name=rec.table_name and constraint_name=rec.constraint_name order by position;
      dbms_utility.table_to_comma(const_list,i,constraints);
      found:=false;
      for rec_idx in (select index_name from user_ind_columns where table_name=rec.table_name) loop
        i:=null;
        idx_list:=null_array;
        select column_name bulk collect into idx_list from user_ind_columns where table_name=rec.table_name and index_name=rec_idx.index_name order by column_position;
        dbms_utility.table_to_comma(idx_list,i,idxs);
        if idxs=constraints then
          found:=true;
          exit;
        end if;
      end loop;
      if not found then
        dbms_output.put_line('create index '||rec.constraint_name||'_FKI on '||rec.table_name||'('||constraints||') parallel nologging;');
      end if;
  end loop;
end;
/
