col event format A30
col TOTAL_TIMEOUTS format 999999
col AVERAGE_WAIT heading AVG_WAIT


select event,TOTAL_WAITS,TOTAL_TIMEOUTS,
	TIME_WAITED, AVERAGE_WAIT
from 
	v$system_event
order by 4
;


