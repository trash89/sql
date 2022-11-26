set lines 200 pages 200
select  substr(destination,1,4) "Dest"
        ,substr(qname,1,20) "Queue"
        ,to_char(failures,'999') "Fail"
        ,to_char(last_run_date,'HH24:MI') "Last"
        ,to_char(next_run_date,'HH24:MI') "Next"
        ,trunc(latency) "Lat."
        ,trunc(avg_time,2) "Avg time"
        ,total_number
        ,schedule_disabled
from dba_queue_schedules
order by failures,destination;
set lines 200 pages 22

