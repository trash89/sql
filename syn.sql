--
--  Script    : syn.sql
--  Purpose   : show synonyms FROM dba_synonyms
--  Tested on : 10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 155 pages 50
undef own
accept own char prompt 'Owner?(%)      : ' default ''

col owner           for a30
col synonym_name    for a30
col table_owner     for a30
col table_name      for a30
col db_link         for a30
ttitle left 'dba_synonyms'
SELECT 
     owner
    ,synonym_name
    ,table_owner
    ,table_name
    ,db_link
FROM 
    dba_synonyms
WHERE
   owner LIKE upper('%&&own%')
ORDER BY 
     owner
    ,synonym_name
    ,table_owner
;

undef own

ttitle off
set feed off
SELECT 
     table_owner
    ,count(*)
FROM 
    dba_synonyms
GROUP BY
    table_owner
;

@rest_sqp_set
