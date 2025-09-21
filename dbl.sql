--
--  Script    : dbl.sql
--  Purpose   : show database links FROM dba_db_links
--  Tested on : 10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 125 pages 50
col owner           for a30
col db_link         for a30
col username        for a30
col host            for a30
ttitle left 'dba_db_links'
SELECT 
     owner
    ,db_link
    ,username
    ,host 
FROM 
    dba_db_links
ORDER BY 
     owner
    ,db_link
;

@rest_sqp_set
