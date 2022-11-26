@save_sqlplus_settings

set lines 200 pages 200 trims off trim on
undef own
undef tab
undef tbs
accept tbs char prompt 'Tablespace?(%) :' default ''
accept own char prompt 'Table Owner?(%):' default ''
accept tab char prompt 'Table?(%)      :' default ''
col tab 			for a49 	head 'Owner.Table.Partition_Name/Tablespace_Name'
col pct_free_used 		for a6 		head 'Pct|fr/usd'
col ini_max 			for a9 		head 'Ini/Max'
col freelists 			for 9 		head 'F|L'
col num_rows 			for 99999999 	head 'Nr|Rows'
col blo 			for a10 	head 'Blks|Used/Empty'
col sprow 			for a12 	head 'AvgSp/Row/Ch'
col lasta 			for a10 	head 'Last|Anlz'
col composite 			for a1 		head 'C'
col subpartition_count 		for 999 	head 'Part|Cnt'
col partition_position 		for 999 	head 'Part|Pos'
col subpartition_position 	for 999 	head 'Part|Pos'
col buffer_pool 		for a7 		head 'Buffer|Pool'
col stats 			for a5 		head 'Gl/Us|Stats'
col sample 			for a5 		head 'Samp|Size'
col logging                     for a4          head 'Logg'

prompt From DBA_TAB_PARTITIONS
select 
   table_owner||'.'||table_name||'.'||partition_name||'/'||tablespace_name as tab, 
   partition_position,
   substr(composite,1,1) as composite,
   subpartition_count,
   logging,
--   high_value,
--   high_value_length,
   to_char(pct_free)||'/'||to_char(pct_used) as pct_free_used,
   to_char(ini_trans)||'/'||to_char(max_trans) as ini_max,
   freelists,
   num_rows,
   to_char(blocks)||'/'||to_char(empty_blocks) as blo,
   to_char(avg_space)||'/'||to_char(avg_row_len)||'/'||to_char(chain_cnt)  sprow,
   to_char(last_analyzed,'dd/mm/rrrr') as lasta,
   to_char(nvl(num_rows,1)/nvl(sample_size,1)*100,'999')||'%' sample,
   buffer_pool,
   substr(global_stats,1,1)||'/'||substr(user_stats,1,1) as stats
from dba_tab_partitions
where 
     table_owner like upper('%&&own%') and 
     table_name like upper('%&&tab%') and 
     (tablespace_name like upper('%&&tbs%') or tablespace_name is null) and
     table_owner not in 
		     ('SYS',
                      'SYSTEM',
                      'OUTLN',
                      'DBSNMP',
                      'CTXSYS',
                      'DRSYS',
                      'MDSYS',
                      'ORDSYS',
                      'ORDPLUGINS',
                      'TRACESVR')
order by 
	table_owner,
	table_name,
	partition_position;

col tab 			for a56 	head 'Owner.Table.Partition_Name.Subpart_Name/Tbs_Name'
prompt
prompt From DBA_TAB_SUBPARTITIONS
select 
   table_owner||'.'||table_name||'.'||partition_name||'.'||subpartition_name||'/'||tablespace_name as tab, 
   subpartition_position,
   to_char(pct_free)||'/'||to_char(pct_used) as pct_free_used,
   to_char(ini_trans)||'/'||to_char(max_trans) as ini_max,
   logging,
   freelists,
   num_rows,
   to_char(blocks)||'/'||to_char(empty_blocks) as blo,
   to_char(avg_space)||'/'||to_char(avg_row_len)||'/'||to_char(chain_cnt)  sprow,
   to_char(last_analyzed,'dd/mm/rrrr') as lasta,
   sample_size,
   buffer_pool,
   substr(global_stats,1,1)||'/'||substr(user_stats,1,1) as stats
from dba_tab_subpartitions
where 
     table_owner like upper('%&&own%') and 
     table_name like upper('%&&tab%') and 
     (tablespace_name like upper('%&&tbs%') or tablespace_name is null) and
     table_owner not in 
		     ('SYS',
                      'SYSTEM',
                      'OUTLN',
                      'DBSNMP',
                      'CTXSYS',
                      'DRSYS',
                      'MDSYS',
                      'ORDSYS',
                      'ORDPLUGINS',
                      'TRACESVR')
order by 
	table_owner,
	table_name,
        partition_name,
	subpartition_position;
undef own
undef tab
undef tbs

@restore_sqlplus_settings

