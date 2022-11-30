--aw_objects_in_cache.sql
--This script identifies the objects in the buffer cache that are related to analytic workspaces.

set lines 110 
col username format a10
col object format a30
col subobject format a15
col blocks format 999,999,999
 
select owner username, object_name object, subobject_name subobject, object_type, count(1) blocks from dba_objects dbao, v$bh vbh where dbao.object_id=vbh.objd and dbao.owner in (select username from v$session where sid in (select session_id from v$aw_calc)) and dbao.owner != 'SYS' group by owner, object_name, subobject_name, object_type order by count(1);

