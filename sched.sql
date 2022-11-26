set lines 150 pages 50
column destination format a10
column last_error_msg format a40
select destination,last_error_msg,to_char(last_error_date,'dd/mm/rrrr hh24:mi:ss') last_error_date from dba_queue_schedules
order by destination;
clear columns
set lines 150 pages 22
