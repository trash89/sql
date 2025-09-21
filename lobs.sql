--
--  Script    : lobs.sql
--  Purpose   : show directories for expdp/impdp
--  Tested on : 10g+
--
@save_sqp_set

set lines 217 pages 50

undef own
accept own char prompt 'Owner?(%)      : ' default ''

col tablespace_name     for a30
col tab                 for a60
col column_name         for a48
col segment_name        for a30
col index_name          for a30
col size_mb             for 99,999,999.99
break on tablespace_name nodup on tab nodup
ttitle left 'dba_lobs'
SELECT * FROM (
SELECT
    l.tablespace_name
   ,l.owner||'.'||l.table_name AS tab
   ,l.column_name
   ,l.segment_name
   ,l.index_name
   ,ROUND(s.bytes/1024/1024,2) size_mb
FROM
    dba_lobs l
    JOIN dba_segments s 
ON 
    s.owner = l.owner 
    AND s.segment_name = l.segment_name
WHERE
    l.owner LIKE upper('%&&own%')
ORDER BY size_mb DESC
)
ORDER BY 
     tablespace_name
    ,size_mb
    ,tab
    ,column_name
    ,segment_name
    ,index_name
;

undef own

@rest_sqp_set
