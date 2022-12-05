--
--  Script    : tab.sql
--  Author    : Marius RAICU
--  Purpose   : show tables from all_tables
--  Tested on : Oracle 19c

@save_sqlplus_settings

set lines 211 pages 22 trims off trim on
undef tab
undef tbs
undef own
accept own char prompt 'Owner?(%)      :' default ''
accept tbs char prompt 'Tablespace?(%) :' default ''
accept tab char prompt 'Table?(%)      :' default ''
col owner for a20 head 'Owner'
col table_owner for a20 head 'TableOwner'
column trigger_name format a39 head 'Trigger Name'
column trigger_type format a15 head 'Trigger Type'
column tablespace_name format a20 head 'Tablespace'
column tab format a39 head 'Table'
col logging for a4 head 'Log?'
col partitioned for a5 head 'Part?'
col row_mov for a7 head 'RowMov?'
col monitoring for a5 head 'Moni?'
column pct_free_used format a6 head '%f/%us'
column ini_max format a10 head 'Ini/Max/Fl'
column num_rows format 99999999 head 'NrRows'
column blo format a13 head 'Blk/Empty'
column degrI format a7 head 'Paral'
column part format a13 head 'Cached/Tmp/Nes'
column splen format a10 head 'AvgSp/Row'
column chain_cnt format 99999 head 'ChCnt'
column avg_row_len format 999999 head 'AvgRow'
column lasta format a10 head 'LastAnl'
column ininext format a10 head 'KIni/Next'
select 
   owner,
   tablespace_name,
   table_name as tab,
   logging,
   partitioned,
   substr(row_movement,1,5) as row_mov,
   monitoring,
   trim(degree)||'/'||trim(instances) as degrI,
   num_rows,
   to_char(last_analyzed,'dd/mm/rrrr') as lasta,   
   chain_cnt,
   trim(cache)||'/'||trim(temporary)||'/'||trim(nested) as part,
   to_char(blocks)||'/'||to_char(empty_blocks) as blo,
   to_char(avg_space)||'/'||to_char(avg_row_len) as splen,
   to_char(ini_trans)||'/'||to_char(max_trans)||'/'||to_char(freelists) as ini_max,
   to_char(initial_extent/1024)||'/'||to_char(next_extent/1024) as ininext,
   to_char(pct_free)||'/'||to_char(pct_used) as pct_free_used
from 
   all_tables 
where 
   owner like upper('%&&own%') and table_name like upper('%&&tab%') and (tablespace_name like upper('%&&tbs%') or tablespace_name is null)
order by 
   owner,num_rows,table_name ;

prompt Triggers:
select 
  owner,
  table_owner,
  table_name as tab,
  trigger_name,
  trigger_type
from
   all_triggers
where 
   table_owner like upper('%&&own%') and table_name like upper('%&&tab%')
order by 
   table_owner,table_name,trigger_type ;
undef tab
undef tbs
undef own

@restore_sqlplus_settings

--@@show_meta