--
--  Script    : idx_ogg.sql
--  Purpose   : show OGGUK_ indexes FROM dba_indexes (indexes created for renforcing OGG unicity of tables without PH/UK)
--  Tested on : 10g,11g,12c,19c
--
@save_sqp_set

set lines 156 pages 50

undef own
accept own char prompt 'Owner?(%)      : ' default ''

col idx              for a60            head 'Index'
col index_type       for a25            head 'Type'
col table_name       for a30            head 'Table'
col tablespace_name  for a30            head 'Tablespace'

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
   AND index_name like 'OGGUK%'
ORDER BY
   table_name
  ,num_rows
;

undef own

@rest_sqp_set
