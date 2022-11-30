--
--  Script    : obj.sql
--  Author    : Marius RAICU
--  Purpose   : show objects from all_objects
--  Tested on : Oracle 19c

@save_sqlplus_settings

set lines 206 pages 22 trims off trim on
undef own
undef objtype

set lines 200 pages 22 trims off trim on

accept own     char prompt 'Owner?(%)                             :' default ''
accept objtype char prompt 'Object Type(TABLE,INDEX,etc)?(%)      :' default ''

col owner for a20 head 'Owner'
col obj format a39 head 'Object Name'
col subobj format a39 head 'SubObject Name'
col object_type for a22 head 'Object Type'
col object_id for 9999999 head 'Obj ID'
col temporary for a4 head 'Temp'
col generated for a3 head 'Gen'
col secondary for a3 head 'Sec'

select 
  owner,
  object_name as obj,
  subobject_name as subobj,
  object_type,
  created,
  last_ddl_time,
  status,
  object_id,
  temporary,
  generated,
  secondary 
from 
  all_objects
where
  owner like upper('%&&own%') and object_type like upper('%&&objtype%')
order by 
  owner,
  object_type,
  object_name;

select owner,object_type,count(0) 
from 
  all_objects 
where
  owner like upper('%&&own%') and object_type like upper('%&&objtype%')
group by 
  owner,object_type 
order by 1,2;

undef own
undef objtype

@restore_sqlplus_settings

--@@show_meta