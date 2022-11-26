/**********************************************************************
 * File:	sysevent.sql
 * Type:	SQL*Plus script
 * Author:	Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:	04-Oct-99
 *
 * Description:
 *	This is possibly one of the most useful tuning scripts
 *	available.
 *
 *	The V$SYSTEM_EVENT dynamic performance view is the highest-level
 *	view of the "Session Wait Interface".  Information in this view
 *	is cumulative since the database instance was started, and one
 *	can get a very good idea of what types of contention a database
 *	instance is (or is not) experiencing by monitoring this view.
 *
 *	NOTE: this script sorts output by the TIME_WAITED column in the
 *	V$SYSTEM_EVENT view.  If the Oracle initialization parameter
 *	TIMED_STATISTICS is not set to TRUE, then the TIME_WAITED
 *	column will not be populated.
 *
 *	Please *disregard* the advice of people who insist that turning
 *	off TIMED_STATISTICS is somehow a performance boost.  Whatever
 *	performance overhead that might be incurred is more than
 *	compensated for by the incredible tuning information that
 *	results...
 *
 * Modifications:
 *	TGorman	10jan01	added "% of Concern" functionality to try to
 *			strip out "benign" wait events and the impact
 *			that they appear to have...
 *********************************************************************/
set echo off feedback off timing off pause off verify off
set pagesize 100 linesize 500 trimspool on trimout on
col event format a26 truncate heading "Event Name"
col total_waits format 999,990.00 heading "Total|Waits|(in 1000s)"
col total_timeouts format 999,990.00 heading "Total|Timeouts|(in 1000s)"
col time_waited format 999,990.00 heading "Time|Waited|(in Hours)"
col pct_significant format 90.00 heading "% of|Concern"
col average_wait format 990.00 heading "Avg|Wait|(Secs)"

col instance new_value V_INSTANCE noprint
select	lower(replace(t.instance,chr(0),'')) instance
from	sys.v_$thread        t,
	sys.v_$parameter     p
where	p.name = 'thread'
and	t.thread# = to_number(decode(p.value,'0','1',p.value));

col total_time_waited new_value V_TOTAL_TIME_WAITED noprint
select	sum(time_waited) total_time_waited
from	sys.v_$system_event
where	event not in ('SQL*Net message from client',
		      'rdbms ipc message',
		      'slave wait',
		      'pmon timer',
		      'smon timer',
		      'rdbms ipc reply',
		      'SQL*Net message to client',
		      'SQL*Net break/reset to client',
		      'inactive session',
		      'Null event')
/

select	event,
	(total_waits / 1000) total_waits,
	(total_timeouts / 1000) total_timeouts,
	(time_waited / 360000) time_waited,
	decode(event,
		'SQL*Net message from client', 0,
		'rdbms ipc message', 0,
		'slave wait', 0,
		'pmon timer', 0,
		'smon timer', 0,
		'rdbms ipc reply', 0,
		'SQL*Net message to client', 0,
		'SQL*Net break/reset to client', 0,
		'inactive session', 0,
		'Null event', 0,
		(time_waited / &&V_TOTAL_TIME_WAITED)*100) pct_significant,
	(average_wait / 100) average_wait
from	sys.v_$system_event
where	(time_waited/360000) >= 0.01
order by pct_significant desc, time_waited desc

spool sysevent_&&V_INSTANCE
/
spool off
