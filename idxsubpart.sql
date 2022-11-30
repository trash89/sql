--
--  Script    : idxsubpart.sql
--  Author    : Marius RAICU
--  Purpose   : show index subpartions for an index partition from all_ind_subpartitions
--  Tested on : Oracle 19c


@save_sqlplus_settings

set lines 210 pages 200 trims off trim on
undef idx
undef tbs
undef prt
undef own
accept own char prompt 'Owner?(%)      :' default ''
accept tbs char prompt 'Tablespace?(%) :' default ''
accept idx char prompt 'Index?(%)      :' default ''
accept prt char prompt 'Partition?(%)  :' default ''
col owner for a15 head 'Owner'
column tablespace_name format a15 head 'Tablespace'
column part format a55 head 'PartPos SubpPos  Index     Partition       Subpartition'
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
   index_owner as owner,
   tablespace_name,
   to_char(partition_position,'999')||' '||to_char(subpartition_position,'999')||' '||index_name||' '||partition_name||' '||subpartition_name as part,
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
   all_ind_subpartitions
where 
     index_owner like upper('%&&own%') and index_name like upper('%&&idx%') and partition_name like upper('%&&prt%') and (tablespace_name like upper('%&&tbs%') or tablespace_name is null)
order by 
   index_owner,index_name,partition_position;

undef tbs
undef idx
undef prt
undef own
@restore_sqlplus_settings

--@@show_meta