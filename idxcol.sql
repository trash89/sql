--
--  Script    : idxcol.sql
--  Purpose   : show index columns for a specific index FROM dba_ind_columns
--  Tested on : 10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 163 pages 50
undef tab
undef idx
undef own
accept own char prompt 'Owner?(%)      : ' default ''
accept idx char prompt 'Index?(%)      : ' default ''
accept tab char prompt 'Table?(%)      : ' default ''

col table_name       for a30      head 'Table'
col idx              for a60      head 'Index'
col column_name      for a30      head 'ColName'
col column_position  for 999,999  head 'ColPos'
break on table_name nodup on idx nodup skip 1
ttitle left 'dba_ind_columns'
SELECT
   table_name
  ,index_owner||'.'||index_name as idx
  ,column_name
  ,column_position
  ,column_length
  ,char_length
  ,descend
FROM
   dba_ind_columns
WHERE
   index_owner LIKE upper('%&&own%')
   AND index_name LIKE '%'||upper(substr('&&idx%',instr('&&idx%','.')+1))
   AND table_name LIKE '%'||upper(substr('&&tab%',instr('&&tab%','.')+1))   
ORDER BY
   index_owner
  ,table_name
  ,index_name
  ,column_position
;

undef tab
undef idx
undef own

@rest_sqp_set
