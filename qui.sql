select owner,count(0) 
from dba_tables
where owner not in ('SYS','SYSTEM','DBSNMP','PUBLIC') 
group by owner order by count(0);

