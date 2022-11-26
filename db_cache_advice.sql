--
--  Script  : db_cache_advice.sql
--  Purpose : Show the V$DB_CACHE_ADVICE 
--  Author  : Marius RAICU
--  For     : Oracle9i
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

set lines 200 pages 200

col size_for_estimate 		for 999,999,999,999 	head  'Cache Size (m)'  
col buffers_for_estimate 	for 999,999,999 	head  'Buffers'  
col estd_physical_read_factor 	for 999.90 		head  'Estd Phys|Read Factor'  
col estd_physical_reads 	for 999,999,999 	head  'Estd Phys| Reads'  

break on name skip 1 on block_size skip 1

SELECT 
        name,
        block_size,
	size_for_estimate, 
	buffers_for_estimate , 
	estd_physical_read_factor, 
	estd_physical_reads 
FROM 
	V$DB_CACHE_ADVICE 
WHERE 
	advice_status =  'ON' 
ORDER BY
        name,block_size;
clear columns
clear breaks

col gethitratio for 99999.99
col pinhitratio for 99999.99
col invalidations head 'Inval'
col dlm_lock_requests head 'DLM Locks|Requests'
col dlm_pin_requests  head 'DLM Pin|Requests'
col dlm_pin_releases  head 'DLM Pin|Releases'
col dlm_invalidation_requests head 'DLM Inval|Requests'
col dlm_invalidations head 'DLM|Inval'
select 
	*
from 
	v$librarycache;
clear columns

select 
	*
from
	v$pgastat;
SELECT 
	to_number(decode(SID, 65535, NULL, SID)) sid, 
	operation_type OPERATION, 
	trunc(WORK_AREA_SIZE/1024) WSIZE, 
	trunc(EXPECTED_SIZE/1024) ESIZE, 
	trunc(ACTUAL_MEM_USED/1024) MEM, 
	trunc(MAX_MEM_USED/1024) "MAX MEM", 
	NUMBER_PASSES PASS 
FROM 
	V$SQL_WORKAREA_ACTIVE 
ORDER BY 
	1,2;

SELECT 
	operation, 
	options, 
	object_name name, 
	trunc(bytes/1024/1024) "input(MB)", 
	trunc(last_memory_used/1024) last_mem, 
	trunc(estimated_optimal_size/1024) optimal_mem, 
	trunc(estimated_onepass_size/1024) onepass_mem, 
	decode(optimal_executions, null, null, optimal_executions|| '/' ||onepass_executions|| '/' || multipasses_executions) "O/1/M" 
FROM 
	V$SQL_PLAN p, V$SQL_WORKAREA w 
WHERE 
        p.object_owner not in ('SYS','SYSTEM') and
	p.address=w.address(+) AND 
	p.hash_value=w.hash_value(+) AND 
	p.id=w.operation_id(+);

@restore_sqlplus_settings
