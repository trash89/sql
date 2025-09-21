--
--  Script    : tabcol.sql
--  Purpose   : show informations and stats about columns for a table, FROM dba_tables, dba_tab_columns, dba_tab_col_statistics
--  Tested on : 10g+
--
@save_sqp_set

set lines 200 pages 50

undef tab
undef own
accept own char prompt 'Owner?(%)      : ' default ''
accept tab char prompt 'Table?(%)      : ' default ''
col tab           for a60           head 'Table'
col column_id     for 99            head 'No'
col coldata       for a60           head 'Column'
col num_distinct  for 999,999,999   head 'NumDistinct'
col num_nulls     for 999,999,999   head 'Nulls'
col cardi         for 999.9         head 'Card'
col density       for 9.99999       head 'Density'
col num_buckets   for 999           head 'Buck'
col histo         for a9            head 'Histogram'
col lasta         for a16           head 'LastAnalyzed'

break on tab skip 1 nodup
ttitle left 'dba_tab_columns'
SELECT
  a.owner||'.'||a.table_name as tab
 ,a.column_id
 ,a.column_name||' '||a.data_type||'('||to_char(a.data_length)||')' as coldata
 ,b.num_distinct
 ,b.num_nulls
 ,(b.num_distinct*100)/nvl(nullif(c.num_rows,0),1) as cardi
 ,b.density
 ,b.num_buckets
 ,substr(trim(b.histogram),1,8)                                      as histo
 ,to_char(b.last_analyzed,'dd/mm/rrrr hh24:mi')                      as lasta
FROM
  dba_tab_columns        a
 ,dba_tab_col_statistics b
 ,dba_tables             c
WHERE
  a.owner LIKE upper('%&&own%')
  AND a.table_name LIKE '%'||upper(substr('&&tab%',instr('&&tab%','.')+1))   
  AND a.owner=c.owner
  AND a.table_name=c.table_name
  AND a.owner=b.owner
  AND a.table_name=b.table_name
  AND a.column_name=b.column_name
ORDER BY
  a.owner
 ,a.table_name
 ,a.column_id
;

col tab             for a60 head 'Table'
col column_name     for a30
col ENCRYPTION_ALG  for a30
col INTEGRITY_ALG   for a12
ttitle left 'dba_encrypted_columns'
SELECT 
     owner||'.'||table_name as tab
    ,column_name
    ,ENCRYPTION_ALG
    ,INTEGRITY_ALG
FROM 
    dba_encrypted_columns
WHERE
    owner LIKE upper('%&&own%')
    AND table_name LIKE '%'||upper(substr('&&tab%',instr('&&tab%','.')+1))   
ORDER BY
     1
    ,2
;

undef tab
undef tbs
undef own

@rest_sqp_set
