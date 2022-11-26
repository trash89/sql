set serveroutput on size unlimited
declare
  cnt pls_integer:=0;
  string1 varchar2(32365):=null;
  string2 varchar2(32365):=null;
begin
  for rec in (select a.index_name,a.table_name from user_indexes a where a.index_type='BITMAP' and a.generated='N' and a.index_name not like '%PK' and a.index_name not like 'PK%' and a.index_name not like '%UK' and a.index_name not like '%IDX%' and table_name like 'INC_FT%') loop
    cnt:=0;
    select count(0) into cnt from user_ind_columns where index_name=rec.index_name;
    if cnt=1 then
      begin
      string2:='drop index '||rec.index_name;
      for rec1 in (select column_name from user_ind_columns where index_name=rec.index_name) loop
        begin
          string1:='create index '||rec.index_name||' on '||rec.table_name||'('||rec1.column_name||') nologging parallel';
          execute immediate string2;
          execute immediate string1;
        exception
        when others then 
          begin
            begin
              string1:='create index '||rec.index_name||' on '||rec.table_name||'('||rec1.column_name||') nologging parallel local';
              execute immediate string1;
            exception
              when others then dbms_output.put_line(string1);
            end;
          end;
        end;
      end loop;
      exception
        when others then dbms_output.put_line(sqlerrm||' '||string1);
      end;
    end if;
  end loop;
end;
/