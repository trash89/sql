col owner format A10
col segment_name format A30
col TABLESPACE_NAME format A30
select OWNER,SEGMENT_NAME,SEGMENT_TYPE,TABLESPACE_NAME
from dba_extents
where FILE_ID = &file_id
and &extid between BLOCK_ID and (BLOCK_ID + BLOCKS)
/
