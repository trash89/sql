set lines 110
select tablespace_name,segment_type,owner,count(*) from dba_segments
group by tablespace_name,segment_type,owner
/
set lines 80 pages 0
