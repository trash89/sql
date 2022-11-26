@save_sqlplus_settings

set lines 200 pages 22 trims off trim on
undef own
undef tab
undef tbs
accept tbs char prompt 'Tablespace?(%) :' default ''
accept own char prompt 'Owner?(%)      :' default ''
accept tab char prompt 'Table?(%)      :' default ''
column tab format a39 head 'Table'
column pct_free_used format a6 head '%f/us'
column ini_max format a10 head 'Ini/Max/Fl'
column num_rows format 99999999 head 'NrRows'
column blo format a13 head 'Used/EmptyBlk'
column degrI format a7 head 'Degr'
column part format a24 head 'Ch/Part/Tmp/Nes/RowM/Mon'
column splen format a10 head 'AvgSp/Row'
column chain_cnt format 99999 head 'ChCnt'
column avg_row_len format 999999 head 'AvgRow'
column lasta format a10 head 'LastAnl'
column ininext format a10 head 'KIni/Next'
select 
   owner||'.'||table_name as tab, 
   to_char(pct_free)||'/'||to_char(pct_used) as pct_free_used,
   to_char(initial_extent/1024)||'/'||to_char(next_extent/1024) as ininext,
   to_char(ini_trans)||'/'||to_char(max_trans)||'/'||to_char(freelists) as ini_max,
   num_rows,
   to_char(blocks)||'/'||to_char(empty_blocks) as blo,
   to_char(avg_space)||'/'||to_char(avg_row_len) as splen,
   chain_cnt,
--   avg_space_freelist_blocks,
--   num_freelist_blocks,
   substr(trim(degree),1,3)||'/'||substr(trim(instances),1,3) as degrI,
   to_char(last_analyzed,'dd/mm/rrrr') as lasta,
   cache||'/'||partitioned||'/'||temporary||'/'||nested||'/'||substr(row_movement,1,3)||'/'||monitoring as part
from dba_all_tables 
where 
     owner like upper('%&&own%') and table_name like upper('%&&tab%') and (tablespace_name like upper('%&&tbs%') or tablespace_name is null)
     and owner not in 
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
                      'WKSYS',
      'XDB',
      'WMSYS',
      'WK_TEST',
      'WK_PROXY',
      'SYSMAN',
      'SI_INFORMTN_SCHEMA',
      'SCOTT',
      'MGMT_VIEW',
      'MDDATA',
      'EXFSYS',
      'DMSYS',
      'ANONYMOUS',
      'BC4J') 
order by owner,num_rows ;
undef own
undef tab
undef tbs

@restore_sqlplus_settings
