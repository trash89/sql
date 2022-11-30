/* aw_wait_events.sql
Describes the wait events experienced by users of analytic workspaces 
over the previous hour.
*/

col awuser format a25
col awname format a20
col event format a25
col state format a8

select username||' ('||sid||','||serial#||')' as awuser, owner||'.'||aw_name||' ('||decode(attach_mode, 'READ WRITE', 'RW', 'READ ONLY', 'RO', attach_mode)||')' awname, decode(state, 'WAITING', a.event, null) event, state, count(*) cnt, sum (time_waited) waited from v$active_session_history a, v$session b, v$aw_olap c, dba_aws d where  sid=a.session_id and sid=c.session_id and sample_time > sysdate - (1/24) and c.aw_number=d.aw_number group by username, sid, serial#, owner, aw_name, attach_mode,  decode(state, 'WAITING', a.event, null), state;
