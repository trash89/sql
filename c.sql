@save_sqlplus_settings
set lines 81 pages 80 feed off
col cons form A8 head "Cons"
col send form A8   head "Send"
col queue form a15 head "Queue"
col mess form 99999
select
	trim(queue) as queue,
	trim(sender_name) as send,
	trim(consumer_name) as cons,
	substr(msg_state,1,5) as state,
	count(*) as mess,
	to_char(min(enq_time),'DD/MM/RRRR HH24:MI') as enq,
	to_char(max(deq_time),'DD/MM/RRRR HH24:MI') as deq
from aqadm.aq$queue_tab
group by
	queue,sender_name,consumer_name,msg_state
order by
	min(enq_time);
@restore_sqlplus_settings
