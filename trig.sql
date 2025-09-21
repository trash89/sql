--
--  Script    : trig.sql
--  Purpose   : show triggers FROM dba_triggers
--  Tested on : 10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 153 pages 50
undef tab
undef own
accept own char prompt 'Owner?(%)      : ' default ''
accept tab char prompt 'Table?(%)      : ' default ''

col tab           for a60
col trig          for a60 head 'Trigger Name'
col trigger_type  for a20 head 'Trigger Type'
col status        for a8  head 'Status'
ttitle left 'dba_triggers'
SELECT
   table_owner||'.'||table_name as tab
  ,owner||'.'||trigger_name as trig
  ,trigger_type
  ,status
FROM
   dba_triggers
WHERE
   table_owner LIKE upper('%&&own%')
   AND table_name LIKE '%'||upper(substr('&&tab%',instr('&&tab%','.')+1))   
ORDER BY
   table_owner
  ,table_name
  ,trigger_type
;

undef tab
undef own

@rest_sqp_set
