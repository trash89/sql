select
  a.owner,a.table_name,a.next_extent,a.tablespace_name
from 
  all_tables a,(select 
                     tablespace_name,max(bytes) as big_chunk
                from
                     dba_free_space
                group by 
                     tablespace_name) f
where 
  f.tablespace_name=a.tablespace_name and 
  a.next_extent>f.big_chunk
/

