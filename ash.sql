
col sql_id for a13
col pctload for 999.99
select sql_id,count(*), round(count(*)/sum(count(*)) over (),2) pctload
from v$active_session_history
where sample_time > sysdate - 1/24/60 and  ---- last minute
      session_type <> 'BACKGROUND'
group by sql_id
order by count(*) asc;


select ash.sql_id, count(*) from
v$active_session_history ash, v$event_name evt
where
	ash.sample_time > sysdate-1/24/60	and
	ash.session_state = 'WAITING' and
	ash.event_id = evt.event_id and
	evt.wait_class = 'User I/O' 
group by sql_id
order by count(*) asc;

select e.event, e.total_waits-nvl(b.total_waits,0) total_waits,e.time_waited-nvl(b.time_waited,0) time_waited
from v$active_session_history b,v$active_session_history e,stats$snapshot sn
where snap_time>sysdate-&1 and 
		e.event not like '%timer' and 
		e.event not like '%message%' and 
		e.event not like '%slave wait%' and 
		e.snap_id=sn.snap_id and 
		b.snap_id=e.snap_id-1 and 
		b.event = e.event and 
		e.total_timeouts > 100 and 
		(e.total_waits-b.total_waits > 100 or e.time_waited-b.time_waited > 100)
;


