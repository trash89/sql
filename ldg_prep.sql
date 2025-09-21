--
--  Script    : ldg_prep.sql
--  Purpose   : show the schemas,tables and columns potentially not supported for logical standby
--  Tested on : 11g,12c,19c
--
@save_sqp_set

set lines 100 pages 50

--SELECT
--    DISTINCT data_type
--FROM
--    dba_tab_columns
--WHERE
--    (data_type NOT LIKE 'KU%'
--    AND data_type NOT LIKE 'HSB%'
--    AND data_type NOT LIKE 'ORA$%'
--    AND data_type NOT LIKE 'SCHEDULER%'
--    AND data_type NOT LIKE 'WM$%'
--    AND data_type NOT LIKE 'WRI$%'
--    AND data_type NOT LIKE 'SYS$%'
--    AND data_type NOT LIKE 'AQ$%'
--    AND data_type NOT LIKE 'RE$%'
--    AND data_type NOT LIKE 'DBMS_DBFS%'
--    AND data_type NOT LIKE 'CHAR%'
--    AND data_type NOT LIKE 'DATE%'
--    AND data_type NOT LIKE 'NCHAR%'
--    AND data_type NOT LIKE 'NVARCHAR%'
--    AND data_type NOT LIKE 'NUMBER'
--    AND data_type NOT LIKE 'TIMESTAMP%'
--    AND data_type NOT LIKE 'VARCHAR2%')
--ORDER BY
--    1;

ttitle left 'dba_logstdby_skip, users not supported for Logical Data Guard'
SELECT
    owner
FROM
    dba_logstdby_skip
WHERE
    statement_opt='INTERNAL SCHEMA'
ORDER BY
    owner
;

col tab for a90 head 'Table'
ttitle left 'dba_logstdby_unsupported, tables not supported for Logical Data Guard'
SELECT DISTINCT tab FROM (
    SELECT
        owner||'.'||table_name||'  '||attributes as tab
    FROM
        dba_logstdby_unsupported
)    
ORDER BY
    tab
;

col tab         for a60 head 'Table'
col bad_column  for a15 head 'Bad Column'
ttitle left 'dba_logstdby_not_unique, tables without UK/PK key'
SELECT
    owner||'.'||table_name as tab, bad_column
FROM
    dba_logstdby_not_unique
ORDER BY 
     tab
    ,bad_column
;

@rest_sqp_set
