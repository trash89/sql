
@save_sqlplus_settings

col owner          for a15 head 'User'
col session_id             head 'SID'
col mode_held      for a20 head 'Lock Mode|Held'
col mode_requested for a20 head 'Lock Mode|Requested'
col type                   head 'Type|Object'
col name                   head 'Object|Name'
set pages 59 lines 200
prompt Report on All DDL Locks Held
select nvl(owner, 'SYS') owner,
       session_id,
       name,
       type,
       mode_held,
       mode_requested
from   sys.dba_ddl_locks
order by 2;

prompt Report on All DML Locks Held
select nvl(owner, 'SYS') owner, 
       session_id, 
       name, 
       mode_held, 
       mode_requested
from   sys.dba_dml_locks
order by 2;
clear columns
set pages 22 lines 80

@restore_sqlplus_settings

