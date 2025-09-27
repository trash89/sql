--
--  Script    : idx.sql
--  Purpose   : show indexes FROM dba_indexes
--  Tested on : 10g,11g,12c,19c
--
@save_sqp_set

set lines 156 pages 50

undef idx
undef tab
undef own
accept own char prompt 'Owner?(%)      : ' default ''
accept idx char prompt 'Index?(%)      : ' default ''
accept tab char prompt 'Table?(%)      : ' default ''

col idx              for a60            head 'Index'
col index_type       for a25            head 'Type'
col table_name       for a30            head 'Table'
col tablespace_name  for a30            head 'Tablespace'
col stat             for a6             head 'Status'
col num_rows         for 99,999,999,999 head 'NrRows'
col distinct_keys    for 99,999,999,999 head 'Distinct Keys'
col lasta            for a10            head 'LastAnlz'
col ini_trans        for 999            head 'IniT'
col pct_free         for 999            head '%f'
col degree           for a3             head 'Par'
col partitioned      for a4             head 'Part'
col logging          for a4             head 'Logg'
col uniq             for a6             head 'Unique'
col compr            for a5             head 'Compr'
col join_index       for a4             head 'Join'
col generated        for a3             head 'Gen'
set feed off
ttitle left 'dba_indexes'
SELECT
   owner||'.'||index_name                 as idx
  ,index_type  
  ,table_name
  ,tablespace_name
FROM
   dba_indexes
WHERE
   owner LIKE upper('%&&own%')
   AND index_name LIKE '%'||upper(substr('&&idx%',instr('&&idx%','.')+1))
   AND table_name LIKE '%'||upper(substr('&&tab%',instr('&&tab%','.')+1))   
ORDER BY
   table_name
  ,num_rows
;

ttitle off
set feed on
SELECT
   owner||'.'||index_name                 as idx
  ,substr(status,1,6)                     as stat   
  ,num_rows
  ,distinct_keys
  ,to_char(last_analyzed,'dd/mm/rrrr')    as lasta
  ,ini_trans
  ,pct_free
  ,substr(trim(degree),1,3)               as degree
  ,partitioned
  ,logging
  ,substr(uniqueness,1,6)                 as uniq
  ,substr(compression,1,5)                as compr
  ,join_index
  ,generated
FROM
   dba_indexes
WHERE
   owner LIKE upper('%&&own%')
   AND index_name LIKE '%'||upper(substr('&&idx%',instr('&&idx%','.')+1))
   AND table_name LIKE '%'||upper(substr('&&tab%',instr('&&tab%','.')+1))   
ORDER BY
   table_name
  ,num_rows
;

undef idx
undef tab
undef own

@rest_sqp_set
