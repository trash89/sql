SET FEED OFF FLUSH OFF VERIFY OFF pages 200 LINES 200
COLUMN tablespace_name heading TablespaceName  format a30
COLUMN free_bytes      heading 'Free MBytes' format 9999999.99
COLUMN perc_free       heading '% Free' format 999.99
COLUMN free_blocks     heading 'Free Blk'
set lines 150 pages 200
COLUMN tablespace_name heading TablespaceName  format a30
COLUMN segment_type heading SegType  format a10
COLUMN segment_name heading SegType  format a30
break on report
compute sum of free_bytes on report
SELECT f.tablespace_name,
       sum(d.bytes)/1024/1024 free_bytes,
       ((sum(d.bytes)/1024/1024)/(sum(f.bytes)/1024/1024))*100 perc_free,
       sum(d.blocks) free_blocks
FROM dba_free_space d,dba_data_files f
where d.tablespace_name=f.tablespace_name
GROUP BY f.tablespace_name;
select tablespace_name,
       initial_extent/1024 as INI_EXT_K,
       next_extent/1024 as NEXT_EXT_K,
       min_extents,
       max_extents,
       pct_increase,
       status,
       contents,
       logging
--     ,extent_management
from dba_tablespaces;
CLEAR columns
SET FEED ON FLUSH ON VERIFY ON pages 22 LINES 150
CLEAR columns
clear computes
clear breaks
