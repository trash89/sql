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
column part format a5 head 'Cache'
column avg_space format 99999 head 'AvgSp'
column chain_cnt format 99999 head 'ChCnt'
column avg_row_len format 999999 head 'AvgRow'
column lasta format a10 head 'LastAnl'
select 
   t.owner||'.'||t.table_name as tab, 
   to_char(t.pct_free)||'/'||to_char(t.pct_used) as pct_free_used,
   to_char(t.ini_trans)||'/'||to_char(t.max_trans) as ini_max,
   t.freelists,
   t.num_rows,
   to_char(t.blocks)||'/'||to_char(t.empty_blocks) as blo,
   t.avg_space,
   t.chain_cnt,
   t.avg_row_len,
   ltrim(rtrim(t.degree))||'/'||ltrim(rtrim(t.instances)) as degrI,
   t.cache as part
from dba_tables t
where 
     t.owner like '%&&own%' and t.table_name like '%&&tab%' and t.tablespace_name like '%&&tbs%'
order by t.owner,t.num_rows ;
select t.owner||'.'||t.table_name as tab,
       max(to_char(t.last_analyzed,'dd/mm/rrrr')) as lasta
from dba_tab_columns t
where
     t.owner like '%&&own%' and t.table_name like '%&&tab%'
group by t.owner||'.'||t.table_name;
undef own
undef tab
undef tbs
set lines 80 pages 22 feed on head on
