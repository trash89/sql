--
--  Script    : segs.sql
--  Author    : Marius RAICU
--  Purpose   : show segments from user_segments
--  Tested on : Oracle 19c

@save_sqlplus_settings

set lines 200 pages 200 trims off trim on
undef tbs
compute sum of bytesM label 'Total(Mb)' on report
break on report
accept tbs char prompt "In which Tablespace? :"
col segment_type for a20
col segment_name format a38
col bytesM for 999999.999999 head 'Size(Mb)'
select 
  tablespace_name,segment_type,segment_name,count(*) as num_segments,sum(bytes/1024/1024) as bytesM
from 
  user_segments
where 
  tablespace_name like upper('%&&tbs%') 
group by 
  tablespace_name,segment_type,segment_name
order by 
  tablespace_name,segment_type,segment_name;
undef tbs

@restore_sqlplus_settings

--@@show_meta