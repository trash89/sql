--
--  Script    : sess_res10.sql
--  Purpose   : This script provides information about cursor usage, PGA, and UGA 
--              for each open session. This information is not restricted to analytic workspaces or their users.
--  Tested on : 10g,11g 
--
@save_sqp_set

set lines 78 pages 50

col username    for a25
col name        for a30
break on sid nodup on username nodup skip 1
ttitle left 'v$sesstat, v$session'
SELECT
    vsst.sid
   ,vses.username
   ,vstt.name
   ,max(vsst.value)              value
FROM
    gv$sesstat  vsst
   ,gv$statname vstt
   ,gv$session  vses
WHERE
    vsst.inst_id=vstt.inst_id
    AND vsst.inst_id=to_number(sys_context('USERENV','INSTANCE'))      
    AND vsst.inst_id=vses.inst_id
    AND vstt.statistic#=vsst.statistic#
    AND vsst.sid=vses.sid
    AND vstt.name IN('session pga memory','session pga memory max','session uga memory','session uga memory max','session cursor cache count','session cursor cache hits','session stored procedure space','opened cursors current','opened cursors cumulative')
    AND vses.username IS NOT NULL
GROUP BY
    vsst.sid
   ,vses.username
   ,vstt.name
ORDER BY
    vsst.sid
   ,vses.username
   ,vstt.name
;

@rest_sqp_set
