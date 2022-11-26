set lines 200 pages 22 trims off trim on
undef own
undef tab
undef tbs
accept tbs char prompt 'Tablespace?(%) :' default ''
accept own char prompt 'Owner?(%)      :' default ''
accept tab char prompt 'Table?(%)      :' default ''
column tab format a39 head 'Table'
column pct_free_used format a7 head '%free/used'
column ini_max format a9 head 'Ini/MaxTr'
column freelists format 99 head 'FrL'
column num_rows format 99999999 head 'NrRows'
column blo format a10 head 'Used/EmptyBlk'
column degrI format a5 head 'Degree/Inst'
column part format a21 head 'Ch/Part/Tmp/Nes'
column avg_space format 99999 head 'AvgSp'
column chain_cnt format 99999 head 'ChCnt'
column avg_row_len format 999999 head 'AvgRow'
column lasta format a10 head 'LastAnl'
select 
   owner||'.'||table_name as tab, 
   to_char(pct_free)||'/'||to_char(pct_used) as pct_free_used,
   to_char(ini_trans)||'/'||to_char(max_trans) as ini_max,
   freelists,
   num_rows,
   to_char(blocks)||'/'||to_char(empty_blocks) as blo,
   avg_space,
   chain_cnt,
   avg_row_len,
--   avg_space_freelist_blocks,
--   num_freelist_blocks,
   ltrim(rtrim(degree))||'/'||ltrim(rtrim(instances)) as degrI,
   to_char(last_analyzed,'dd/mm/rrrr') as lasta,
   cache||'/'||partitioned||'/'||temporary||'/'||nested as part
from dba_tables 
where 
     owner like '%&&own%' and table_name like '%&&tab%' and tablespace_name like '%&&tbs%'
order by owner,num_rows ;
undef own
undef tab
undef tbs
set lines 80 pages 22 feed on head on
