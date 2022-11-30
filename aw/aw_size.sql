/* aw_size.sql
This script reports the amount of space used by analytic workspaces
and the tablespaces in which they are stored.
*/

set pages 500 lines 110 
bre on REPORT; 
comp sum lab "Total Disk:" of mb on REPORT; 

col awname format a40 heading "Analytic Workspace" 
col tablespace_name format a20 heading "Tablespace" 
col mb format 999,999,990.00 heading "On Disk MB" 

select dbal.owner||'.'||substr(dbal.table_name,4) awname, 
       sum(dbas.bytes)/1024/1024 as mb, dbas.tablespace_name 
from   dba_lobs dbal, dba_segments dbas 
where  dbal.column_name = 'AWLOB' and dbal.segment_name = dbas.segment_name 
group by dbal.owner, dbal.table_name, dbas.tablespace_name 
order by dbal.owner, dbal.table_name;
