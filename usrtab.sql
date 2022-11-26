set line 110
set pagesize 80

select 
substr(a.table_name,1,15) "table"
,substr(b.tablespace_name,1,10) "tablespace"
,to_char(b.initial_extent/1024,'999g999g999') "initial"
,to_char(b.next_extent/1024,'999g999g999') "next"
,to_char(b.extents,'999g999') "extents"
,to_char(b.pct_increase,'99g99') "Pctincrease"
,to_char(b.bytes/1024/1024,'999g999') "size Mo"
,to_char((a.num_rows*a.avg_row_len)/1024/1024,'999g999') "real Mo"
,to_char(a.num_rows,'999g999g999') "rows"
,to_char(a.avg_row_len,'999g999') "avg len"
from dba_tables a,dba_segments b
where 
a.owner='&owner'
and b.owner=a.owner
and b.segment_name=a.table_name
and b.segment_type='TABLE'
order by
b.bytes

/
