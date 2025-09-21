--
--  Script    : seq.sql
--  Purpose   : show sequences FROM dba_sequences
--  Tested on : 10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 160 pages 50

undef own
accept own char prompt 'Owner?(%)      : ' default ''

col seq                 for a60                   head 'Sequence'
col last_number         for 99999999999999999999  head 'Last Number'
col min_value           for 99999999999999999999  head 'Min Value'
col increment_by        for 999999                head 'IncrBy'
col cache_size          for 999999999             head 'Cache'
col cycle_flag          for a5                    head 'Cycle'
col order_flag          for a5                    head 'Order'
ttitle left 'dba_sequences'
SELECT
   sequence_owner||'.'||sequence_name              as seq
  ,last_number
  ,min_value
  ,increment_by
  ,cache_size
  ,cycle_flag
  ,order_flag
FROM
   dba_sequences
WHERE
   sequence_owner LIKE upper('%&&own%')
ORDER BY
   sequence_owner
  ,sequence_name
;

undef own

@rest_sqp_set
