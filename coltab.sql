--
--  Script    : coltab.sql
--  Author    : Marius RAICU
--  Purpose   : show informations and stats about columns for a table, from all_tab_columns, all_tab_col_statistics
--  Tested on : Oracle 19c

@save_sqlplus_settings

set lines 200 pages 100 trims off trim on
undef tab
undef own
accept own char prompt 'Owner?(%)      :' default ''
accept tab char prompt 'Table?(%)      :' default ''

col owner for a15 head 'Owner'
col tab for a25 head 'Table'
col colname for a25 head 'Column'
col colid for 99999 head 'ColId'
col datype for a15 head 'DataType(Len)'
col avg_col_len for '999999999' head 'AvgColLen'
col num_distinct for '999999999999' head 'NumDistinct'
col num_nulls for '999999999999' head 'NumNulls'
col density for '9.99999999999' head 'Density'
col num_buckets for '9999' head 'Buck'
col cardi for a7 head '% Cardi'
col lasta for a10 head 'LastAnalyzed'

col histo for a6 head 'Histo?'

select  a.owner,
        a.table_name as tab,
        a.column_name as colname,
        a.column_id as colid,        
        a.data_type||'('||to_char(a.data_length)||')' as datype,
        b.avg_col_len,
        b.num_distinct,
        b.num_nulls,        
        to_char((b.num_distinct*100)/nvl(nullif(c.num_rows,0),1),'999.99') as cardi,
        b.density,
        b.num_buckets,
        substr(trim(b.histogram),1,5) as histo,
        to_char(b.last_analyzed,'dd/mm/rrrr') as lasta   
from 
    all_tab_columns a, all_tab_col_statistics b,all_tables c
where
  a.owner like upper('%&&own%') and a.table_name like upper('%&&tab%') and
  a.owner=c.owner and a.table_name=c.table_name and
  a.owner=b.owner and a.table_name=b.table_name and a.column_name=b.column_name 
order by 
    a.owner,a.table_name,a.column_id;

undef tab
undef tbs
undef own

@restore_sqlplus_settings

--@@show_meta
