SET FEED OFF FLUSH OFF VERIFY OFF pages 200 LINES 200
COLUMN tablespace_name heading TablespaceName  format a30
COLUMN free_megs       heading 'Free MBytes' format 9999999.99
COLUMN perc_free       heading '% Free' format 999.99
COLUMN free_blocks     heading 'Free Blk'
COLUMN tablespace_name heading TablespaceName  format a30
COLUMN segment_type heading SegType  format a10
COLUMN segment_name heading SegType  format a30

set lines 80 pages 200
break on report
compute sum of free_bytes on report

col Alloc form 999g999g999
col Free form 999g999g999
col PCT_REMP form 999.99

select 
substr(tablespace_name,1,25) "Tablespace" 
,round(sum(lalloc)/1024/1024) "SizeMB" 
,round(sum(lfree)/1024/1024) "FreeMB"
,round((sum(lalloc)-sum(lfree))/sum(lalloc)*100,2) "% Full"
,count(lfree)-1 "Frgt"
from
(select tablespace_name,bytes lalloc,0 lfree
from dba_data_files
union all
select tablespace_name 
, 0 lalloc
,bytes lfree
from dba_free_space
)
group by tablespace_name
order by 4;

set lines 150 pages 200

column ini_ext format 9999999 head 'Ini_Ext|Ko'
column next_ext format 9999999 head 'Next_Ext|Ko'
column min_extents format 99999 head 'Min_Ext'
column pct_increase format 99 head '%Incr'
select tablespace_name,
       initial_extent/1024 as ini_ext,
       next_extent/1024 as next_ext,
       min_extents,
       max_extents,
       pct_increase,
       status,
       substr(contents,1,4) as contents
from dba_tablespaces;
CLEAR columns
SET FEED ON FLUSH ON VERIFY ON pages 22 LINES 150
CLEAR columns
clear computes
clear breaks
