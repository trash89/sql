set lines 200 pages 22 trims off trim on

col obj format a39 head 'Object Name'
col object_type for a22 head 'Object Type'
col object_id for 9999999 head 'Obj ID'
col temporary for a4 head 'Temp'
col generated for a3 head 'Gen'
col secondary for a3 head 'Sec'

select 
   object_name as obj,
   object_type,
   created,
   last_ddl_time,
   status,
   object_id,
   temporary,
   generated,
   secondary 
from user_objects
where object_type not like '%PARTITION%'
order by 
  object_type,
  object_name;

select object_type,count(0) from user_objects group by object_type order by 1;

clear col
set lines 80 pages 22 feed on head on
