col name form A50
select name,value, statistic# 
from v$sysstat
where upper(name) like upper('%&1%');
