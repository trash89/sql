--
--  Script    : idxcol.sql
--  Author    : Marius RAICU
--  Purpose   : show index columns for a specific index
--  Tested on : Oracle 19c

@save_sqlplus_settings

set lines 206 pages 22 trims off trim on
undef tab
undef idx
accept tab char prompt 'Table?(%)      :' default ''
accept idx char prompt 'Index?(%)      :' default ''
column tab format a15 head 'Table'
column idx format a15 head 'Index'
column col_name format a20 head 'ColName'
column col_position format 999999999 head 'ColPos'

select 
   table_name as tab, 
   index_name as idx, 
   column_name as col_name,
   column_position as col_position,
   column_length,
   char_length,
   descend
from user_ind_columns
where 
     table_name like upper('%&&tab%') and index_name like upper('%&&idx%')
order by table_name,index_name,column_position ;
undef tab
undef idx

@restore_sqlplus_settings

prompt To obtain the DDL for a table or index, execute the following:
prompt SET LONG 20000000
prompt SET PAGESIZE 0
prompt EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false);;
prompt EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SEGMENT_ATTRIBUTES',false);;
prompt EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'TABLESPACE',false);;
prompt select dbms_metadata.get_ddl('INDEX','IDX_TEST') from dual;;
prompt select dbms_metadata.get_ddl('TABLE','TEST') from dual;;
