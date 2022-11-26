@save_sqlplus_settings
set lines 90 pages 80 feed on
column avg_size format 99999.99
select  substr(destination,1,4) "Dest"
        ,substr(qname,1,20) "Queue"
        ,to_char(failures,'999') "Fail"
        ,to_char(last_run_date,'HH24:MI') "Last"
        ,to_char(next_run_date,'HH24:MI') "Next"
        ,trunc(latency) as lat
        ,trunc(avg_time,2) "Avg time"
        ,total_number
        ,schedule_disabled
        ,avg_size
from dba_queue_schedules
order by destination;
@restore_sqlplus_settings
