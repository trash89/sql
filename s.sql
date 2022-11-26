set line 200 pages 80
select substr(a.username,1,10) "User"
,to_char(a.sid,'999') "SID"
,to_char(a.serial#,'999999') "Serial#"
,b.spid "SPID"
,substr(a.osuser,1,10) "OS"
,substr(a.terminal,1,10) "Terminal"
,substr(a.program,1,50) "Program"
,a.status "Status"
,c.name
from v$session a
,v$process b
,v$bgprocess c
where b.pid(+)=a.sid
and c.paddr(+)=b.addr
order by logon_time;

