/* olap_pga_use.sql
This script calculates the amoung of PGA that the OLAP page pool
is consuming for all users.
*/

select 'OLAP Pages Occupying: '|| round((((select sum(nvl(pool_size,1)) from v$aw_calc)) / (select value from v$pgastat where name = 'total PGA inuse')),2)*100||'%' info 
from dual union select 'Total PGA Inuse Size: '||value/1024||' KB' info from v$pgastat where name = 'total PGA inuse' union select 'Total OLAP Page Size: '|| round(sum(nvl(pool_size,1))/1024,0)||' KB' info from v$aw_calc order by info desc;
