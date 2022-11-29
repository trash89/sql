@save_sqlplus_settings

set lines 200 pages 22 trims off trim on
undef tab
undef tbs
accept tbs char prompt 'Tablespace?(%) :' default ''
accept tab char prompt 'Table?(%)      :' default ''
column tab format a39 head 'Table'
column pct_free_used format a6 head '%f/%us'
column ini_max format a10 head 'Ini/Max/Fl'
column num_rows format 99999999 head 'NrRows'
column blo format a13 head 'Blk/Empty'
column degrI format a7 head 'Paral'
column part format a30 head 'Part/Cached/Tmp/Nes/RowM/Mon'
column splen format a10 head 'AvgSp/Row'
column chain_cnt format 99999 head 'ChCnt'
column avg_row_len format 999999 head 'AvgRow'
column lasta format a10 head 'LastAnl'
column ininext format a10 head 'KIni/Next'
select 
   table_name as tab, 
   to_char(pct_free)||'/'||to_char(pct_used) as pct_free_used,
   to_char(initial_extent/1024)||'/'||to_char(next_extent/1024) as ininext,
   to_char(ini_trans)||'/'||to_char(max_trans)||'/'||to_char(freelists) as ini_max,
   num_rows,
   to_char(last_analyzed,'dd/mm/rrrr') as lasta,   
   to_char(blocks)||'/'||to_char(empty_blocks) as blo,
   to_char(avg_space)||'/'||to_char(avg_row_len) as splen,
   chain_cnt,
   trim(degree)||'/'||trim(instances) as degrI,
   trim(partitioned)||'/'||trim(cache)||'/'||trim(temporary)||'/'||trim(nested)||'/'||trim(row_movement)||'/'||trim(monitoring) as part
from user_tables 
where 
     table_name like upper('%&&tab%') and (tablespace_name like upper('%&&tbs%') or tablespace_name is null)
order by num_rows,table_name ;
undef tab
undef tbs

@restore_sqlplus_settings
