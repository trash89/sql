--
--  Script    : iot.sql
--  Purpose   : show IOTs tables FROM dba_tables
--  Tested on : 10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 200 pages 50

undef tab
undef own
accept own char prompt 'Owner?(%)      : ' default ''
accept tab char prompt 'Table?(%)      : ' default ''

col tablespace_name     for a30           head 'Tablespace'
col tab                 for a60           head 'Table'
col iot_type            for a12           head 'IOT Type'
col iot_name            for a30           head 'IOT Name'
col num_rows            for 999,999,999   head 'NrRows'
col lasta               for a10           head 'LastAnlz'
col avg_row_len         for 99,999        head 'AvgRowL'
col blocks              for 999,999       head 'Blocks'
col ini_trans           for 999           head 'IniT'
col pct_free            for 999           head '%f'
col partitioned         for a4            head 'Part'
col logging             for a3            head 'Log'
col rowm                for a4            head 'RowM'
ttitle left 'dba_tables - IOTs'
SELECT
   tablespace_name
  ,owner||'.'||table_name              as tab
  ,iot_type
  ,iot_name
  ,num_rows
  ,to_char(last_analyzed,'dd/mm/rrrr') as lasta  
  ,avg_row_len  
  ,blocks  
  ,ini_trans
  ,pct_free
  ,partitioned
  ,logging
  ,substr(row_movement,1,4)            as rowm
FROM
   dba_tables
WHERE
   owner LIKE upper('%&&own%')
   AND table_name LIKE '%'||upper(substr('&&tab%',instr('&&tab%','.')+1))   
   AND (iot_type IS NOT NULL or iot_name IS NOT NULL)
ORDER BY
   owner
  ,num_rows
  ,table_name
;

undef tab
undef own

@rest_sqp_set
