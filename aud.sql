set lines 120 pages 22
column os format a25
column username format a15
column timestamp format a14
column obj format a25
column action_name format a10
select 
	to_char(timestamp,'dd/mm/rr hh24:mi') as timestamp,
	terminal||'-'||os_username os,
	username,
	owner||'.'||obj_name as obj,
	action_name 
from 
	dba_audit_trail 
order by 
	timestamp,
	os_username;
clear columns

