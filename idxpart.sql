--
--  Script    : idxpart.sql
--  Purpose   : show index partions for an index FROM dba_ind_partitions
--  Tested on : 10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 180 pages 50

undef idx
undef own
accept own char prompt 'Owner?(%)      : ' default ''
accept idx char prompt 'Index?(%)      : ' default ''

col tablespace_name        for a30        head 'Tablespace'
col part                   for a76        head 'Index           Partition'
col partition_position     for 999        head 'Pos'
col composite              for a6         head 'Compos'
col subpartition_count     for 99,999     head 'SubPCnt'
col num_rows               for 9,999,999,999 head 'NrRows'
col lasta                  for a10        head 'LastAnlz'
col stat                   for a6         head 'Status'
col pct_free               for 999        head '%f'
col logging                for a4         head 'Log'
col compr                  for a5         head 'Compr'
ttitle left 'dba_ind_partitions'
SELECT
   tablespace_name
  ,index_owner||'.'||index_name||' '||partition_name  as part
  ,partition_position
  ,composite
  ,subpartition_count
  ,num_rows
  ,to_char(last_analyzed,'dd/mm/rrrr')                as lasta
  ,substr(trim(status),1,6)                           as stat
  ,pct_free
  ,logging  
  ,substr(trim(compression),1,5)                      as compr  
FROM
   dba_ind_partitions
WHERE
   index_owner LIKE upper('%&&own%')
   AND index_name LIKE '%'||upper(substr('&&idx%',instr('&&idx%','.')+1))
ORDER BY
   index_owner
  ,index_name
  ,partition_position
;

undef idx
undef own

@rest_sqp_set
