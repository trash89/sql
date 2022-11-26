/* cursor_parameters.sql
This script enables you to check whether the current settings for 
the SESSION_CACHED_CURSORS or the OPEN_CURSORS parameters are a
constraint for the current user. If either of the Usage column 
figures approaches 100%, then you should increase that parameter.
This information is not restricted to cursors associated with 
analytic workspaces.
*/

select 'session_cached_cursors' parameter, lpad(value, 5)  value, 
       decode(value, 0, '  n/a', to_char(100 * used / value, '990') || '%') usage
from (select max(s.value) used from v$statname n, v$sesstat s 
       where n.name = 'session cursor cache count' and s.statistic# = n.statistic#),
     (select value from v$parameter where name = 'session_cached_cursors')
union all
select 'open_cursors', lpad(value, 5), to_char(100 * used / value,  '990') || '%'
from (select max(sum(s.value))  used from v$statname  n, v$sesstat  s
       where n.name in ('opened cursors current', 'session cursor cache count') 
         and s.statistic# = n.statistic# group by s.sid ),
     (select value from v$parameter where name = 'open_cursors');
 

