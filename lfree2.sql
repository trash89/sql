set lines 100
column ts_size         heading 'size (Mo)'           format 9,999,999
column used            heading 'Used (Mo)'           format 9,999,999,999
column total_free      heading 'Total|free (Mo)'     format 9,999,999,999
column max_cont_free   heading 'Largest|cont (Mo)'   format 9,999,999,999
column pct_free        heading 'Free|(%)'            format 999
column num_free        heading '# ext'               format 999999


select   fs.tablespace_name
,        ts.bytes / (1024 * 1024)                 ts_size
,        (ts.bytes - fs.bytes) / 1024/1024             used
,        fs.bytes / 1024/1024                          total_free
,        fs.cont / 1024/1024                           max_cont_free
,        round(100 * fs.bytes / ts.bytes)         pct_free
,        fs.gap_count                             num_free
from     ( select   tablespace_name
,        sum(bytes) bytes
,        sum(blocks) blocks
,        count(*) file_count
from     sys.dba_data_files
group by tablespace_name )     ts
,        ( select   tablespace_name
,        sum(bytes) bytes
,        max(bytes) cont
,        count(*) gap_count
from     sys.dba_free_space
group by tablespace_name )  fs
where    ts.tablespace_name = fs.tablespace_name
order by 6 desc
/
