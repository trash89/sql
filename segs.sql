--
--  Script    : segs.sql
--  Author    : Marius RAICU
--  Purpose   : show segments from user_segments
--  Tested on : Oracle 19c

@save_sqlplus_settings

set lines 200 pages 22 trims off trim on
undef tbs
accept tbs char prompt "In which Tablespace? :"
col segment_type for a20
col segment_name format a38
col bytesK for 9999999999 head 'Kb'
select 
  segment_type,segment_name,bytes/1024 as bytesK,blocks,extents 
from 
  user_segments
where 
  tablespace_name like upper('%&&tbs%') 
order by segment_type,segment_name;
undef tbs


@restore_sqlplus_settings

@@show_meta