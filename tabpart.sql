--
--  Script    : tabpart.sql
--  Purpose   : show table partions for a table FROM dba_tab_partitions
--  Tested on : 10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 200 pages 50

undef tab
undef own
accept own char prompt 'Owner?(%)      : ' default ''
accept tab char prompt 'Table?(%)      : ' default ''
col tablespace_name        for a30              head 'Tablespace'
col part                   for a80              head 'Table                Partition'
col partition_position     for 999              head 'Pos'
col composite              for a6               head 'Compos'
col subpartition_count     for 999,999          head 'SubPCnt'
col logging                for a4               head 'Log'
col num_rows               for 999,999,999,999  head 'NrRows'
col lasta                  for a10              head 'LastAnlz'
col blocks                 for 99,999,999,999   head 'Blocks'
col avg_row_len            for 999,999          head 'AvgRowL'
col pct_free               for 999              head '%f'
col compr                  for a4               head 'Comp'
ttitle left 'dba_tab_partitions'
SELECT
   tablespace_name
  ,table_owner||'.'||table_name||' '||partition_name  as part
  ,partition_position
  ,composite
  ,subpartition_count
  ,num_rows
  ,to_char(last_analyzed,'dd/mm/rrrr')                as lasta
  ,blocks                                               
  ,avg_row_len                                             
  ,pct_free
  ,logging
  ,substr(trim(compression),1,4)                      as compr
FROM
   dba_tab_partitions
WHERE
   table_owner LIKE upper('%&&own%')
   AND table_name LIKE '%'||upper(substr('&&tab%',instr('&&tab%','.')+1))   
ORDER BY
   table_owner
  ,table_name
  ,partition_position
;
  
undef tab
undef own

@rest_sqp_set
