--
--  Script    : matvl.sql
--  Purpose   : show materialized view logs FROM dba_mview_logs
--  Tested on : 10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 135 pages 50

undef tab
undef own
accept own char prompt 'Owner?(%)      : ' default ''
accept tab char prompt 'Table?(%)      : ' default ''

col mvl                for a60        head 'Materialized view log'
col master             for a30        head 'Master table'
col rowids             for a10        head 'WithRowids'
col primary_key        for a7         head 'WithPk'
col filter_columns     for a8         head 'FiltCols'
col sequence           for a3         head 'Seq'
col include_new_values for a10        head 'IncludeNew'
ttitle left 'dba_mview_logs'
SELECT 
     log_owner||'.'||log_table as mvl
    ,master
    ,rowids
    ,primary_key
    ,filter_columns
    ,sequence    
    ,include_new_values
FROM 
   dba_mview_logs
WHERE
   log_owner LIKE upper('%&&own%')
   AND master LIKE '%'||upper(substr('&&tab%',instr('&&tab%','.')+1))   
ORDER BY 
     log_owner
    ,master
    ,log_table
;

undef tab
undef own

@rest_sqp_set
