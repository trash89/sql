--
--  Script    : tabpart.sql
--  Author    : Marius RAICU
--  Purpose   : show table partions for a table from user_tab_partitions
--  Tested on : Oracle 19c

@save_sqlplus_settings

set lines 200 pages 22 trims off trim on
undef tab
undef tbs
accept tbs char prompt 'Tablespace?(%) :' default ''
accept tab char prompt 'Table?(%)      :' default ''
column tablespace_name format a20 head 'Tablespace'
column part format a40 head 'Pos Table     Partition'
col composite for a6 head 'Compos'
col subpartition_count for 999999 head 'SubPCnt'
col logging for a4 head 'Log'
column pct_free_used format a6 head '%f/%us'
column ininext format a10 head 'KIni/Next'
column ini_max format a10 head 'Ini/Max/Fl'
column num_rows format 99999999 head 'NrRows'
column lasta format a10 head 'LastAnl'
column blo format a13 head 'Blk/Empty'
column splen format a10 head 'AvgSp/Row'
column chain_cnt format 99999 head 'ChCnt'

col compr for a6 head 'Compr?'
col rest for a14 head 'Nest/Interv/RO'

select 
   tablespace_name,
   to_char(partition_position,'999')||' '||table_name||' '||partition_name as part,
   composite, 
   subpartition_count,
   logging,   
   chain_cnt,
   substr(trim(compression),1,3) as compr,
   num_rows,
   to_char(last_analyzed,'dd/mm/rrrr') as lasta,   
   to_char(blocks)||'/'||to_char(empty_blocks) as blo,
   to_char(avg_space)||'/'||to_char(avg_row_len) as splen,
   to_char(ini_trans)||'/'||to_char(max_trans)||'/'||to_char(freelists) as ini_max,
   to_char(initial_extent/1024)||'/'||to_char(next_extent/1024) as ininext,
   to_char(pct_free)||'/'||to_char(pct_used) as pct_free_used,
   is_nested||'/'||interval||'/'||read_only rest
from user_tab_partitions 
where 
   table_name like upper('%&&tab%') and (tablespace_name like upper('%&&tbs%') or tablespace_name is null)
order by 
   table_name,partition_position ;
undef tab
undef tbs

@restore_sqlplus_settings

prompt To obtain the DDL for a table or index, execute the following:
prompt SET LONG 20000000
prompt SET PAGESIZE 0
prompt EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false);;
prompt EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SEGMENT_ATTRIBUTES',false);;
prompt EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'TABLESPACE',false);;
prompt select dbms_metadata.get_ddl('INDEX','IDX_TEST') from dual;;
prompt select dbms_metadata.get_ddl('TABLE','TEST') from dual;;
