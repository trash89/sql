--
--  Script  : db_cache_adv.sql
--  Purpose : Show the V$DB_CACHE_ADVICE
--  For     : 9i+, for versions <12c, comment out -- sys_context('USERENV','CON_ID')=con_id
--
@save_sqp_set

set lines 200 pages 50
set feed off

col size_for_estimate         for 999,999,999,999,999   head 'Cache Size (m)'
col buffers_for_estimate      for 999,999,999,999,999   head 'Buffers'
col estd_physical_read_factor for 999.90                head 'Estd Phys|Read Factor'
col estd_physical_reads       for 999,999,999,999,999   head 'Estd Phys| Reads'
break on name nodup on block_size nodup
ttitle left 'v$db_cache_advice'
SELECT
   name
  ,block_size
  ,size_for_estimate
  ,buffers_for_estimate
  ,estd_physical_read_factor
  ,estd_physical_reads
FROM
   gv$db_cache_advice
WHERE
   advice_status='ON'
   AND inst_id=to_number(sys_context('USERENV','INSTANCE'))
ORDER BY
   name
  ,block_size
;

clear columns
clear breaks
col gets                for 99,999,999,999,999
col gethits             for 99,999,999,999
col gethitratio         for 999.99              head 'Ratio'
col pins                for 99,999,999,999
col pinhits             for 99,999,999,999
col pinhitratio         for 999.99              head 'Ratio'
col invalidations                head 'Inval'
col dlm_lock_requests            head 'DLM Locks|Requests'
col dlm_pin_requests             head 'DLM Pin|Requests'
col dlm_pin_releases             head 'DLM Pin|Releases'
col dlm_invalidation_requests    head 'DLM Inval|Requests'
col dlm_invalidations            head 'DLM|Inval'
col namespace           for a30
col con_id              for 999   head 'Con'
col inst_id             for 99   head 'I'
ttitle left 'v$librarycache'
SELECT *
FROM gv$librarycache
WHERE
   inst_id=to_number(sys_context('USERENV','INSTANCE'))
;

clear columns
clear breaks
col con_id              for 999 head 'Con'
col inst_id             for 99   head 'I'
col value               for 99,999,999,999,999,999
ttitle left 'v$pgastat'
SELECT *
FROM gv$pgastat
WHERE
   inst_id=to_number(sys_context('USERENV','INSTANCE'))
;

--SELECT
--   operation
--  ,options
--  ,object_name                                                                                                   name
--  ,trunc(bytes/1024/1024)                                                                                        "input(MB)"
--  ,trunc(last_memory_used/1024)                                                                                  last_mem
--  ,trunc(estimated_optimal_size/1024)                                                                            optimal_mem
--  ,trunc(estimated_onepass_size/1024)                                                                            onepass_mem
--  ,decode(optimal_executions,NULL,NULL,optimal_executions||'/'||onepass_executions||'/'||multipasses_executions)"O/1/M"
--FROM
--   v$sql_plan     p
--  ,v$sql_workarea w
--WHERE
--   p.object_owner NOT IN('SYS','SYSTEM')
--   AND p.address=w.address(+)
--   AND p.hash_value=w.hash_value(+)
--   AND p.id=w.operation_id(+);

@rest_sqp_set
