undef tbs
accept tbs char prompt "Which Tablespace?:"
column name format a60
select segment_type||' '||owner||'.'||segment_name as name from dba_segments
where tablespace_name='&&tbs' order by segment_type,owner,segment_name;
undef tbs
