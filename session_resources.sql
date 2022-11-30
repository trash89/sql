/* session_resources.sql
This script provides information about cursor usage, PGA, and UGA 
for each open session. This information is not restricted to 
analytic workspaces or their users.
*/

set pages 500 lines 110 trims on
clear col
col name     format a30 
col username format a20

break on username nodup skip 1

select vses.username||':'||vsst.sid username, vstt.name, max(vsst.value) value 
from v$sesstat vsst, v$statname vstt, v$session vses
where vstt.statistic# = vsst.statistic# and vsst.sid = vses.sid and    
    vstt.name in ('session pga memory', 'session pga memory max',
                  'session uga memory','session uga memory max', 
                  'session cursor cache count', 'session cursor cache hits',
                  'session stored procedure space', 'opened cursors current',
                  'opened cursors cumulative') and vses.username is not null
group by vsst.sid, vses.username, vstt.name 
order by vsst.sid, vses.username, vstt.name;
