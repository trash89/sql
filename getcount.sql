--
--  Script    : getcount.sql
--  Purpose   : show the row number from tables in dba_tables
--  Tested on : 10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 250 pages 50

undef own
undef tab
accept own char prompt 'Owner?(%)      : ' default ''
accept tab char prompt 'Table?(%)      : ' default ''

set term off feed off
column current_scn new_value m_current_scn
SELECT current_scn FROM gv$database WHERE inst_id=to_number(sys_context('USERENV','INSTANCE'));
set term on feed on

set head off feed off
spool /tmp/getcount_marius.sql
SELECT 
    'select '''||owner||'.'||table_name||''' as tab,count(0) as num_rows from "'||owner||'"."'||table_name||'" as of scn '||&m_current_scn||';'
FROM dba_tables 
WHERE  
    owner LIKE upper('%&&own%')
    AND table_name LIKE '%'||upper(substr('&&tab%',instr('&&tab%','.')+1))    
ORDER BY
   owner
  ,table_name
;
spool off

set head on feed off
col at_scn          for 99999999999999
col at_timestamp    for a20
select &m_current_scn as at_scn,to_char(scn_to_timestamp(&m_current_scn),'dd/mm/yyyy hh24:mi:ss') as at_timestamp from dual;

set head off feed off trim on trims on echo off show off tab off lines 150 pages 50
col tab             for a60              head 'Table'
col num_rows        for 999,999,999,999
prompt Table                                                                NUM_ROWS
prompt ------------------------------------------------------------ ----------------
@/tmp/getcount_marius.sql

prompt
undef own
undef tab

@rest_sqp_set
