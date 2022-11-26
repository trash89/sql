accept file_id number  prompt 'File_ID  :'
accept block_id number prompt 'Block_ID :'
col owner format a10
col segment_name format a25
col segment_type format a15
col tablespace_name format a15
col file_name format a35
set lines 150 pages 60
select &file_id ,
       block_id ,
       owner ,
       segment_name ,
       segment_type ,
       e.tablespace_name ,
       file_name 
from   dba_extents e,
       dba_data_files f
where  e.file_id = f.file_id
  and  e.block_id <= &block_id
  and  e.block_id + e.blocks > &block_id
/
undef file_id
undef block_id
clear columns
set lines 150 pages 22
