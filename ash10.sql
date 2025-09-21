--
--  Script    : ash10.sql
--  Purpose   : show active session history info, last 5 mins
--  Tested on : 10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 190 pages 50
col sql_id 	for a13
col pctload for 999.99

ttitle left 'v$active_session_history, last 5 min'
SELECT
	a.sql_id
   ,count(*)
   ,round(count(*)/SUM(count(*)) OVER(),2) pctload
FROM
	gv$active_session_history a
WHERE
	a.sample_time>sysdate-5/24/60 ---- last 5 minute
	AND a.session_type<>'BACKGROUND'
	AND a.inst_id=to_number(sys_context('USERENV','INSTANCE'))
--    AND sys_context('USERENV','CON_ID')=a.con_id
GROUP BY
	sql_id
 -- HAVING
	--   count(*)	>1
ORDER BY
	count(*) ASC
;

ttitle left 'v$active_session_history, last 5 min in WAITING'
SELECT
	ash.sql_id
   ,evt.name
   ,count(*)
FROM
	gv$active_session_history ash
   ,gv$event_name             evt
WHERE
    ash.inst_id=evt.inst_id
	AND ash.inst_id=to_number(sys_context('USERENV','INSTANCE'))
	AND ash.sample_time>sysdate-5/24/60
	AND ash.session_state='WAITING'
	AND ash.event_id=evt.event_id
	AND evt.wait_class='User I/O'
--	AND sys_context('USERENV','CON_ID')=ash.con_id
--	AND ash.con_id=evt.con_id
GROUP BY
	sql_id
   ,name
 -- HAVING
	--   count(*)	>1
ORDER BY
	count(*) ASC
;
	
@rest_sqp_set

-- @$ORACLE_HOME/rdbms/admin/ashrpt.sql