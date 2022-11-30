--
--  Script    : idxcol.sql
--  Author    : Marius RAICU
--  Purpose   : show index columns for a specific index from all_ind_columns
--  Tested on : Oracle 19c

@save_sqlplus_settings

set lines 206 pages 200 trims off trim on
undef tab
undef idx
undef own
accept own char prompt 'Owner?(%)      :' default ''
accept tab char prompt 'Table?(%)      :' default ''
accept idx char prompt 'Index?(%)      :' default ''
col owner for a15 head 'Owner'
column tab format a15 head 'Table'
column idx format a15 head 'Index'
column col_name format a20 head 'ColName'
column col_position format 999999999 head 'ColPos'

select 
   index_owner as owner,
   table_name as tab, 
   index_name as idx, 
   column_name as col_name,
   column_position as col_position,
   column_length,
   char_length,
   descend
from all_ind_columns
where 
   index_owner like upper('%&&own%') and table_name like upper('%&&tab%') and index_name like upper('%&&idx%')
order by 
   index_owner,table_name,index_name,column_position ;
undef tab
undef idx
undef own

@restore_sqlplus_settings

--@@show_meta