--
--  Script    : segs.sql
--  Purpose   : show segments and extents FROM dba_extents AND dba_segments
--  Tested on : 8i,9i,10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 164 pages 50
undef tbs
undef own

accept own char prompt "Owner?      : "
accept tbs char prompt "Tablespace? : "

col tablespace_name for a30
col seg             for a60 head 'Segment Name'
col partition_name  for a20
col segment_type    for a20
col bytesM          for 999,999,999.999 head 'Size(MB)'

break on tablespace_name dup on owner dup on segment_type dup on report 
compute sum label 'Total(Mb)' of bytesM on report
ttitle left 'dba_extents'   
SELECT
    tablespace_name
   ,owner||'.'||segment_name  as seg
   ,partition_name
   ,segment_type   
   ,count(*)                  as num_extents
   ,sum(bytes)/1024/1024      as bytesm
FROM
    dba_extents
WHERE
    (tablespace_name LIKE upper('%&&tbs%') or tablespace_name IS NULL)
    AND owner LIKE upper('%&&own%')
GROUP BY
    owner
   ,tablespace_name
   ,segment_type
   ,segment_name
   ,partition_name
ORDER BY
    owner
   ,tablespace_name
   ,segment_type
   ,segment_name
   ,partition_name
;

clear breaks
clear computes
break on tablespace_name dup on owner dup on segment_type dup on report
compute sum label 'Total(Mb) for tbs' of bytesM on tablespace_name
compute sum label 'Total(Mb) for owner' of bytesM on owner
compute sum label 'Total(Mb) General' of bytesM on report
col owner           for a30
ttitle left 'dba_segments'
SELECT
  tablespace_name
 ,owner  
 ,segment_type
 ,count(*)             as num_segments
 ,sum(bytes/1024/1024) as bytesm
FROM
  dba_segments
WHERE
  (tablespace_name LIKE upper('%&&tbs%') or tablespace_name IS NULL)
  AND owner LIKE upper('%&&own%')  
GROUP BY
  owner
 ,tablespace_name
 ,segment_type
ORDER BY
  owner
 ,tablespace_name
 ,segment_type
;

undef tbs
undef own

@rest_sqp_set
