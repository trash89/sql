--
--  Script      : fix_extents.sql
--  Description : Supprime les limites aux niveau des datafiles,tablespaces,tables,table partitions et indexes
--  Autor       : Marius.Raicu@sanofi-aventis.com
--  Creation    : 21/06/2010
--
--

set lines 200 head on trims on trim on
col file_name for a50
spool fix_extents.log

select file_name as "Datafiles to fix" from dba_data_files where MAXBYTES!=0;
select tablespace_name as "Tbs to Fix" from dba_tablespaces where contents='PERMANENT' and allocation_type='USER' and (max_extents!=2147483645 or pct_increase!=0);
select count(*) as "Tables to Fix" from dba_tables where owner like 'SAP%' and MAX_EXTENTS!=2147483645;
select count(*) as "Indexes to Fix" from dba_indexes where owner like 'SAP%' and MAX_EXTENTS!=2147483645;
select count(*) as "Table Parts to Fix" from dba_tab_partitions where table_owner like 'SAP%' and MAX_EXTENT!=2147483645;

declare
begin
  for rec in(select file_name from dba_data_files where MAXBYTES!=0) loop
    execute immediate 'alter database datafile '||chr(39)||rec.file_name||chr(39)||' autoextend on maxsize unlimited' ;
    execute immediate 'alter database datafile '||chr(39)||rec.file_name||chr(39)||' autoextend off';
  end loop;
  for r in (select tablespace_name from dba_tablespaces where contents='PERMANENT' and allocation_type='USER' and (max_extents!=2147483645 or pct_increase!=0)) loop
    execute immediate 'alter tablespace '||r.tablespace_name||' default storage(maxextents unlimited pctincrease 0)';
  end loop;
  for rec in (select owner,table_name from dba_tables where owner like 'SAP%' and MAX_EXTENTS!=2147483645) loop
    execute immediate 'alter table '||rec.owner||'."'||rec.table_name||'" storage(maxextents unlimited pctincrease 0)';
  end loop;
  for rec in (select owner,index_name from dba_indexes where owner like 'SAP%' and MAX_EXTENTS!=2147483645) loop
    execute immediate 'alter index '||rec.owner||'."'||rec.index_name||'" storage(maxextents unlimited pctincrease 0)';
  end loop;
  for rec in (select table_owner,table_name,partition_name from dba_tab_partitions where table_owner like 'SAP%' and MAX_EXTENT!=2147483645) loop
    execute immediate 'alter table '||rec.table_owner||'."'||rec.table_name||'" modify partition "'||rec.partition_name||'" storage(maxextents unlimited pctincrease 0)';
  end loop;
end;
/

select file_name as "Datafiles to fix" from dba_data_files where MAXBYTES!=0;
select tablespace_name as "Tbs to Fix" from dba_tablespaces where contents='PERMANENT' and allocation_type='USER' and (max_extents!=2147483645 or pct_increase!=0);
select count(*) as "Tables to Fix" from dba_tables where owner like 'SAP%' and MAX_EXTENTS!=2147483645;
select count(*) as "Indexes to Fix" from dba_indexes where owner like 'SAP%' and MAX_EXTENTS!=2147483645;
select count(*) as "Table Parts to Fix" from dba_tab_partitions where table_owner like 'SAP%' and MAX_EXTENT!=2147483645;

spool off
