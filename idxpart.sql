--
--  Script    : idxpart.sql
--  Author    : Marius RAICU
--  Purpose   : show index partions for an index from user_ind_partitions
--  Tested on : Oracle 19c


@save_sqlplus_settings

set lines 200 pages 22 trims off trim on
undef idx
undef tbs
accept tbs char prompt 'Tablespace?(%) :' default ''
accept idx char prompt 'Index?(%)      :' default ''
column tablespace_name format a15 head 'Tablespace'
column part format a40 head 'Pos Index     Partition'
col composite for a6 head 'Compos'
col subpartition_count for 999999 head 'SubPCnt'
col stat for a6 head 'Valid?'
col logging for a4 head 'Log'
col interval for a6 head 'Interv'
col compr for a6 head 'Compr?'
column num_rows format 9999999999 head 'NrRows'
column lasta format a10 head 'LastAnl'
column bdc format a20 head 'BLev/DistK/CluFact'
column blo format a20 head 'LeafBlk/Avg-BpK/DpK'
column ini_max format a10 head 'Ini/Max/Fl'
column ininext format a10 head 'KIni/Next'
column pct_free_used format a6 head '%f/%us'

select 
   tablespace_name,
   to_char(partition_position,'999')||' '||index_name||' '||partition_name as part,
   composite, 
   subpartition_count,
   substr(trim(status),1,5) as stat,
   logging,
   interval,
   substr(trim(compression),1,3) as compr,
   num_rows,
   to_char(last_analyzed,'dd/mm/rrrr') as lasta,   
   to_char(blevel)||'/'||to_char(distinct_keys)||'/'||to_char(clustering_factor) as bdc,
   to_char(leaf_blocks)||'/'||to_char(avg_leaf_blocks_per_key)||'/'||to_char(avg_data_blocks_per_key) as blo,
   to_char(ini_trans)||'/'||to_char(max_trans)||'/'||to_char(freelists) as ini_max,
   to_char(initial_extent/1024)||'/'||to_char(next_extent/1024) as ininext,
   to_char(pct_free)||'/'||to_char(pct_increase) as pct_free_used
from 
   user_ind_partitions
where 
     index_name like upper('%&&idx%') and (tablespace_name like upper('%&&tbs%') or tablespace_name is null)
order by 
   index_name,partition_position;

undef tbs
undef idx
@restore_sqlplus_settings

prompt ---------------- To obtain the DDL for a table or index, execute the following: ---------------------------------------;
prompt SET LONG 20000000;
prompt SET PAGESIZE 0;

prompt execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'PRETTY',true);;
prompt execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SQLTERMINATOR',true);;
prompt execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'STORAGE',false,'TABLE');;
prompt execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'TABLESPACE',false,'TABLE');;
prompt execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'CONSTRAINTS',true,'TABLE');;
prompt execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'REF_CONSTRAINTS',false,'TABLE');;
prompt execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'CONSTRAINTS_AS_ALTER',true,'TABLE');;
prompt execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SIZE_BYTE_KEYWORD',true,'TABLE');;
prompt execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES',false,'TABLE');;
prompt execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES',false,'INDEX');;
prompt execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES',false,'CONSTRAINTS');;
prompt execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'INHERIT',true);;

prompt select dbms_metadata.get_ddl('INDEX','IDX_TEST') from dual;;
prompt select dbms_metadata.get_ddl('TABLE','TEST') from dual;;
prompt ----------------------------------------------------------------------------------------------------------------------;