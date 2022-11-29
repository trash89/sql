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
select segment_type,segment_name,bytes/1024 as bytesK,blocks,extents from user_segments
where tablespace_name like upper('%&&tbs%') order by segment_type,segment_name;
undef tbs


@restore_sqlplus_settings

prompt To obtain the DDL for a table or index, execute the following:
prompt SET LONG 20000000
prompt SET PAGESIZE 0
prompt EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false);;
prompt EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SEGMENT_ATTRIBUTES',false);;
prompt EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'TABLESPACE',false);;
prompt select dbms_metadata.get_ddl('INDEX','IDX_TEST') from dual;;
prompt select dbms_metadata.get_ddl('TABLE','TEST') from dual;;
