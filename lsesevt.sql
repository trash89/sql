col event format A30
col TOTAL_TIMEOUTS format 999999
col AVERAGE_WAIT heading AVG_WAIT


select sid, event, TIME_WAITED
from 
	v$session_event
where 
     sid = &1
union
select sid,'------- CPU used --------', value
from v$sesstat
where statistic# = 12
and     sid = &1
order by TIME_WAITED
;


