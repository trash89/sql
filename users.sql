set lines 200 pages 200
column username format a25 head 'User'
column user_id format 999 head 'UId'
column password format a15 head 'Pwd'
column account_status format a20 head 'Status'
column lock_date head 'LockD'
column expiry_date head 'ExpD'
column default_tablespace format a25 head 'Default TBS'
column temporary_tablespace format a25 head 'Temp TBS'
column created head 'Created'
column profile format a10 head 'Profile'
column initial_rsrc_consumer_group format a10 head 'IniRSRCConsGR'
column external_name format a10 head 'ExtName'
select 
    username,user_id,account_status,default_tablespace,temporary_tablespace,to_char(created,'dd/mm/yyyy hh24:mi:ss') as created 
from 
    dba_users 
order by 
    username;
clear columns
set lines 80 pages 22

