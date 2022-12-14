--
--  Script    : idx.sql
--  Author    : Marius RAICU
--  Purpose   : show indexes in the current schema from user_indexes
--  Tested on : Oracle 19c

@save_sqlplus_settings

set lines 223 pages 22 trims off trim on
undef tab
undef tbs
undef own
accept own char prompt 'Owner?(%)      :' default ''
accept tbs char prompt 'Tablespace?(%) :' default ''
accept tab char prompt 'Table?(%)      :' default ''
accept idx char prompt 'Index?(%)      :' default ''
col owner for a15 head 'Owner'
column tablespace_name format a15 head 'Tablespace'
column tab format a15 head 'Table'
column idx format a15 head 'Index'
column idx_type format a7 head 'IdxType'
col logging for a4 head 'Log?'
col stat for a5 head 'Valid'
col uniq for a4 head 'Uniq'
col visib for a5 head 'Visib'
col compr for a8 head 'Compress'
col part for a6 head 'Partit'
column degrI format a7 head 'Paral'
col constra for a6 head 'Constr'
col distinct_keys for 9999999999 head 'DistKeys'
column num_rows format 9999999999 head 'NrRows'
column lasta format a10 head 'LastAnl'
column bdc format a20 head 'BLev/DistK/CluFact'
column blo format a20 head 'LeafBlk/Avg-BpK/DpK'
column ini_max format a10 head 'Ini/Max/Fl'
column ininext format a10 head 'KIni/Next'
column pct_free_used format a6 head '%f/%us'

select 
   owner,
   tablespace_name,
   table_name as tab, 
   index_name as idx, 
   substr(trim(index_type),1,7) as idx_type,
   logging,
   substr(trim(status),1,5) as stat,
   substr(trim(uniqueness),1,4) as uniq,
   substr(trim(visibility),1,5) as visib,
   substr(trim(compression),1,8) as compr,
   trim(partitioned) as part,
   trim(degree)||'/'||trim(instances) as degrI,
   trim(constraint_index) as constra,
   num_rows,
   to_char(last_analyzed,'dd/mm/rrrr') as lasta,   
   to_char(blevel)||'/'||to_char(distinct_keys)||'/'||to_char(clustering_factor) as bdc,
   to_char(leaf_blocks)||'/'||to_char(avg_leaf_blocks_per_key)||'/'||to_char(avg_data_blocks_per_key) as blo,
   to_char(ini_trans)||'/'||to_char(max_trans)||'/'||to_char(freelists) as ini_max,
   to_char(initial_extent/1024)||'/'||to_char(next_extent/1024) as ininext,
   to_char(pct_free)||'/'||to_char(pct_increase)||'/'||to_char(pct_threshold) as pct_free_used
from all_indexes
where 
     owner like upper('%&&own%') and table_name like upper('%&&tab%') and index_name like upper('%&&idx%') and (tablespace_name like upper('%&&tbs%') or tablespace_name is null)
order by num_rows,table_name ;
undef tab
undef tbs
undef own
@restore_sqlplus_settings

--@@show_meta