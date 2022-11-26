
@save_sqlplus_settings

set lines 110 pages 80 trims on trim on
column tablespace_name format a15
column segment_type format a15
column seg format a45
select /*+ rule */ tablespace_name,segment_type,owner||'.'||segment_name seg,count(*) from dba_extents
where owner not in ('SYS','SYSTEM')
group by tablespace_name,segment_type,segment_name,owner
order by count(*);

set lines 80 pages 22
clear columns

@restore_sqlplus_settings

