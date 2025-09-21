--
--  Script    : tseg.sql
--  Purpose   : show the temporary segment usage by sessions
--  Tested on : 12c,19c
--
@save_sqp_set

set lines 190 pages 50

col sid              for 99999 head 'Sid'
col sql_id           for a13
col operation_type   for a60
break on sid nodup on SQL_ID nodup
ttitle left 'v$sql_workarea_active'
SELECT
   sid
  ,SQL_ID
  ,operation_type
  ,trunc(work_area_size/1024)            wa_size
  ,trunc(expected_size/1024)             exp_size
  ,trunc(actual_mem_used/1024)           actual_mem
  ,trunc(max_mem_used/1024)              max_mem_used
  ,number_passes
  ,con_id
FROM
   gv$sql_workarea_active
WHERE
   inst_id=to_number(sys_context('USERENV','INSTANCE'))   
ORDER BY
   1
  ,2
;

clear breaks

col username    for a25
col usterm      for a30 head 'OSUser@machine'
ttitle left 'v$sort_usage, v$session'
SELECT
    b.sid
   ,a.sql_id
   ,sum(a.blocks*to_number(p.value)/1024)/1024 used_mb
   ,b.username
   ,substr(b.osuser||'@'||b.machine,1,30)    as usterm
FROM
    gv$sort_usage a
   ,gv$session    b
   ,gv$parameter  p
WHERE
    a.inst_id=b.inst_id
    AND a.inst_id=to_number(sys_context('USERENV','INSTANCE'))
    AND a.inst_id=p.inst_id
    AND a.session_addr=b.saddr(+)
    AND p.name='db_block_size'
    AND sys_context('USERENV','CON_ID')=a.con_id
    AND a.con_id=b.con_id
GROUP BY
    b.sid
   ,b.username
   ,a.sql_id
   ,substr(b.osuser||'@'||b.machine,1,30)
ORDER BY
    b.sid
   ,used_mb DESC
;
   
@rest_sqp_set
