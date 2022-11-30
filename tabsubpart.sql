--
--  Script    : tabsubpart.sql
--  Author    : Marius RAICU
--  Purpose   : show table subpartions for a table from user_tab_partitions
--  Tested on : Oracle 19c

@save_sqlplus_settings

set lines 200 pages 22 trims off trim on
undef tab
undef tbs
undef prt
undef own
accept own char prompt 'Owner?(%)      :' default ''
accept tbs char prompt 'Tablespace?(%) :' default ''
accept tab char prompt 'Table?(%)      :' default ''
accept prt char prompt 'Partition?(%)  :' default ''
column tablespace_name format a20 head 'Tablespace'
column part format a55 head 'PartPos SubPPos  Table     Partition      Subpartition'
col owner for a15 head 'Owner'
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
col rest for a9 head 'Interv/RO'

select 
   table_owner as owner,
   tablespace_name,
   to_char(partition_position,'999')||' '||to_char(subpartition_position,'999')||' '||table_name||' '||partition_name||' '||subpartition_name as part,
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
   interval||'/'||read_only rest
from 
   all_tab_subpartitions 
where 
   table_owner like upper('%&&own%') and table_name like upper('%&&tab%') and partition_name like upper('%&&prt%') and (tablespace_name like upper('%&&tbs%') or tablespace_name is null)
order by 
   table_owner,table_name,partition_position,subpartition_position ;
undef tab
undef tbs
undef prt
undef own

@restore_sqlplus_settings

--@@show_meta