--
--  Script    : tabhisto.sql
--  Purpose   : show the histograms for columns in a table FROM dba_histograms
--  Tested on : 8,8i,9i,10g,11g,12c,19c,23c
--
@save_sqp_set

undef own
undef tab
accept own char prompt 'Owner? : ' default '%'
accept tab char prompt 'Table? : ' default '%'
set lines 134 pages 50
col tab           for a60
col column_name   for a45
break on tab skip 1
ttitle left 'dba_histograms'
SELECT
      owner||'.'||table_name as tab
     ,column_name
     ,count(*)
FROM
      dba_histograms
WHERE
      upper(owner) LIKE upper('%&&own%')
      AND table_name LIKE '%'||upper(substr('&&tab%',instr('&&tab%','.')+1))   
GROUP BY
      owner
     ,table_name
     ,column_name
ORDER BY
      owner
     ,table_name
;

clear columns
clear breaks
set verify on
undef own
undef tab

@rest_sqp_set
