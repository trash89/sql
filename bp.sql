--
--  Script : bp.sql
--  Purpose: List the buffer pool statistics
--  Author : Marius RAICU
--  For    : 9i
--

@save_sqlplus_settings

column name 			format a7
column free_buffer_wait 	format 999999 head "FreeBW"
column write_complete_wait 	format 999999 head "WriteCW"
column buffer_busy_wait 	format 999999 head "BufBusyW"
column db_block_gets 		format 9999999999 head "DbBgets"
column consistent_gets 		format 9999999999 head "ConsistGets"
column physical_reads 		format 9999999999 head "PhysReads"
column ratio 			format 999.99 head "Ratio"
select 
       name,
       free_buffer_wait,
       write_complete_wait,
       buffer_busy_wait,
       db_block_gets,
       consistent_gets,
       physical_reads,
       1-(physical_reads/(db_block_gets+consistent_gets)) as ratio 
from 
     v$buffer_pool_statistics;
clear columns

@restore_sqlplus_settings

