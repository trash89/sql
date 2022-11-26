prompt "Oracle Background processes"
select 
substr(a.name,1,10) "Process"
,b.pid
,b.spid
,substr(program,1,15) "Name"
from 
v$bgprocess a
,v$process b 
where 
a.paddr=b.addr
/
