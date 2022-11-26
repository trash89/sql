
@save_sqlplus_settings

undef own
undef tab
accept own char prompt 'Owner ? :[%]' default '%'
accept tab char prompt 'Table ? :[%]' default '%'

set lines 110 pages 80

break on owner skip 1
break on table_name skip 1
col owner for a15 head 'Owner'
select 
a.owner
,substr(a.table_name,1,15) as Table_name
,substr(a.column_name,1,15) "Column"
,substr(a.data_type,1,10) "Data type"
,to_char(a.data_length,'999') "DataLen"
,to_char(a.avg_col_len,'999') "AvgColLen"
,to_char(a.num_distinct,'999g999') "Distincts"
,to_char((a.num_distinct*100)/b.num_rows,'999.99') "% cardi"
,to_char(a.num_nulls,'999g999') "Nulls"
from dba_tab_columns a,dba_tables b
where 
upper(a.owner) like upper('%&own%')
and b.owner=a.owner
and a.table_name like upper('%&tab%')
and b.table_name=a.table_name;

clear breaks
undef own
undef tab

@restore_sqlplus_settings

