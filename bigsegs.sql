--
--  Script    : bigsegs.sql
--  Purpose   : Show big segments in a database
--  Tested on : 10g,11g,12c,19c
--
@save_sqp_set

set lines 164 pages 50

undef own
accept own char prompt 'Owner?(%)      : ' default ''

col seg             for a60 head 'Segment Name'
col segment_type    for a20
col partition_name  for a20
col bytesM          for 999,999,999.999 head 'Size(MB)'
ttitle left 'dba_segments - first 10 biggest segments'
SELECT * FROM (
    SELECT 
         owner||'.'||segment_name   as seg
        ,segment_type
        ,partition_name
        ,sum(bytes)/1024/1024       as bytesM
    FROM 
        dba_segments
    WHERE
        owner LIKE upper('%&&own%')
    GROUP BY 
         owner||'.'||segment_name
        ,segment_type
        ,partition_name
    ORDER BY 
        sum(extents) DESC
    )
WHERE rownum <= 10
order by 
     segment_type
    ,bytesm desc
;

undef own

@rest_sqp_set
