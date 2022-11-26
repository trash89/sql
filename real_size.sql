drop table size_tables;
drop table err_sizes;
whenever sqlerror exit;
create table size_tables(
	owner		varchar2(30),
	table_name	varchar2(30),
	real_size_k	number
)
pctfree 5 pctused 95
storage(initial 64k next 64k minextents 1 maxextents unlimited pctincrease 0);
create table err_sizes(
	message		varchar2(2000)
)
pctfree 5 pctused 95
storage(initial 64k next 64k minextents 1 maxextents unlimited pctincrease 0);

set serveroutput on

declare
  cursor de_table is 
    select owner,table_name
    from dba_tables 
    where owner not in ('SYS','SYSTEM','DBSNMP');
  cursor de_col(puser in varchar2,ptab in varchar2) is
    select column_name 
    from dba_tab_columns 
    where owner=puser and table_name=ptab and data_type not like 'LONG%' and data_type not like '%RAW%';
  col_list varchar2(4000); 
  end_sql varchar2(400);
  c integer;
  r_s number;
  ret number;
  err varchar2(2000);
begin
  for rec in de_table loop
    begin
      col_list:='select ';
      end_sql:=' from '||rec.owner||'.'||rec.table_name;
      for reccol in de_col(rec.owner,rec.table_name) loop
        col_list:=col_list||'nvl(sum(vsize('||reccol.column_name||')),0)+';
      end loop;
      col_list:=substr(col_list,1,length(col_list)-1)||end_sql;
      c:=dbms_sql.open_cursor;
      dbms_sql.parse(c,col_list,dbms_sql.native);  
      dbms_sql.define_column(c,1,r_s);
      ret:=dbms_sql.execute_and_fetch(c);
      if ret!=1 then
        dbms_sql.close_cursor(c);
      end if;
      dbms_sql.column_value(c,1,r_s);
      dbms_sql.close_cursor(c);
      insert into size_tables values(rec.owner,rec.table_name,r_s/1024);
    exception
    when others then 
      err:=sqlerrm;  
      if dbms_sql.is_open(c) then
        dbms_sql.close_cursor(c);
      end if;
      insert into err_sizes values(err||' '||rec.owner||'.'||rec.table_name);
    end;
  end loop;
  commit;
end;
/
set lines 150 pages 200
column real_size_k format 9999999999.99
column real_size_m format 9999999999.99
break on report
compute sum of real_size_k on report
compute sum of real_size_m on report
select owner,table_name,nvl(real_size_k,0) real_size_k,nvl(real_size_k/1024,0) real_size_m 
from size_tables order by real_size_k,owner,table_name;
drop table size_tables;
select * from err_sizes;
drop table err_sizes;
clear columns
clear computes
set lines 150 pages 22
whenever sqlerror continue;
