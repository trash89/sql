--
--  Script    : datatypes.sql
--  Purpose   : show data types FROM dba_tab_columns
--  Tested on : 10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 75 pages 50

undef own
accept own char prompt 'Owner?(%)      : ' default ''

col data_type           for a60              head 'Data Type'
col cnt                 for 9999999          head 'Count'
ttitle left 'dba_tab_columns'
SELECT
     data_type
    ,count(*) as cnt
FROM
    dba_tab_columns
WHERE
    owner LIKE upper('%&&own%')
    AND data_type not like 'KU%'
GROUP BY
    data_type   
ORDER BY
    data_type
;

undef own

@rest_sqp_set
