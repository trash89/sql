select monitoring,count(*) from dba_tables group by monitoring;

alter system set statistics_level='TYPICAL' scope=both;

declare
begin
  for rec in (select owner,table_name from dba_tables where owner not in ('SYS','SYSTEM') and temporary='N') loop
    execute immediate 'alter table '||rec.owner||'."'||rec.table_name||'" monitoring';
  end loop;
end;
/

declare
begin
  for rec in (select owner,index_name from dba_indexes where (owner not in ('SYS','SYSTEM')) and temporary='N') loop
    begin
      execute immediate 'alter index '||rec.owner||'."'||rec.index_name||'" monitoring usage';
    exception 
    	when others then null;
    end;
  end loop;
end;
/