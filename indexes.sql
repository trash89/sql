@save_sqlplus_settings
undef own
undef tab
undef tbs
accept tbs char prompt 'Tablespace?(%) :' default ''
accept own char prompt 'Owner?(%)      :' default ''
accept tab char prompt 'Table?(%)      :' default ''

set lines 200 pages 66
column name format a30 heading 'Name'
#column tablespace_name format a15 heading 'Tablespace|Name'
column pct_free format 99 heading '%|Free'
column ini_trans format 99999 heading 'Ini|Trans'
column max_trans format 99999 heading 'Max|Trans'
column min_extents format 9999 heading 'Min|Exts'
column max_extents format 9999999999 heading 'Max|Exts'
column pct_increase format 999 heading '%|Inc'
column pct_threshold format 999 heading '%|Thr'
column buffer_pool heading 'Buffer|Pool'
column unq format a3 heading 'Unq'
column cmpr format a3 heading 'Cmp'
column ini_max format a9 head 'Trans|Ini/Max'
column ini_next format a9 head 'ExtK|Ini/Next'
column lasta format a10 head 'LastAnl'
column clustering_factor format 999.99 head 'CluF'
column leaf_blocks head 'Leaf|Blocks'
column distinct_keys head 'Distinct|Keys' 
select 
       owner||'.'||index_name as name,
--       table_owner||'.'||table_name as tabl,
--       tablespace_name,
       substr(uniqueness,1,3) as unq,
       substr(compression,1,3) as cmpr,
       pct_free,
       to_char(ini_trans)||'/'||to_char(max_trans) as ini_max,
       to_char(initial_extent/1024)||'/'||to_char(next_extent/1024) as ini_next,
--       min_extents,
--       max_extents,
       pct_increase, 
       pct_threshold,
	blevel,
	leaf_blocks,
	distinct_keys,
	clustering_factor,
	num_rows,
	to_char(last_analyzed,'dd/mm/yyyy') as lasta,
       status
--       buffer_pool
from dba_indexes 
where owner like upper('%&&own%') and table_name like upper('%&&tab%') and (tablespace_name like upper('%&&tbs%') or tablespace_name is null) and
	owner not in 
			('SYS',
                      'SYSTEM',
                      'OUTLN',
                      'DBSNMP',
                      'CTXSYS',
                      'DRSYS',
                      'MDSYS',
                      'ORDSYS',
                      'ORDPLUGINS',
                      'TRACESVR',
                      'AURORA$JIS$UTILITY$',
                      'AURORA$ORB$UNAUTHENTICATED',
                      'LBACSYS',
                      'OLAPDBA',
                      'OLAPSVR',
                      'OLAPSYS',
                      'OSE$HTTP$ADMIN',
                      'WKSYS')
order by owner,table_name,tablespace_name;
clear columns
set lines 150 pages 22
undef own
undef tab
undef tbs

@restore_sqlplus_settings
