-- aw_users.sql
-- This script identifies who is using analytic workspaces.

set pages 500 lines 110 

col username format a12 heading "User" 
col sid format 99999 heading "SID" 
col serial# format 99999 heading "Serial#" 
col aw format a25 heading "AW Name" 
col attch format a5 heading "Mode" 

select username, sid, serial#, owner||'.'||daws.aw_name aw, 
       decode(attach_mode,'READ WRITE','RW','READ ONLY','RO',attach_mode) attch 
from   dba_aws daws,v$aw_olap vawo, v$aw_calc vawc,v$session 
where  daws.aw_number=vawo.aw_number and sid=vawo.session_id and 
       vawc.session_id=sid 
order by username, sid, daws.aw_name;
