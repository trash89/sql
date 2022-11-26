set lines 110 pages 22
column file_name format a40
select file_name, hwm, blocks*4 total_blocks, (blocks-hwm+1)*4 shrinkage_possible
from dba_data_files a,
     ( select file_id, max(block_id+blocks) hwm
       from dba_extents
       group by file_id 
     ) b
where a.file_id = b.file_id;
clear columns
