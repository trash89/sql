/* aw_tablespaces.sql
This script generates a report about the tablespaces in the database
and includes information about analytic workspaces. The following is an
explanation of the output columns.

 Tablespace = name of tablespace 
 TYPE       = U:UNDO T:TEMPORARY P:PERMANENT 
 AUTO       = Is the tablespace auto-extensible Y or N 
 SEGM       = Is the tablespace SEGMENT SPACE MANAGEMENT A:AUTO M:MANUAL 
 PLUG       = Is the tablespace PLUGGED IN Y:YES or N:NO
 LOGG       = Is the tablespace LOGGING Y:LOGGING or N:NOLOGGING 
 LIVE       = Status of the tablespace Y:ONLINE N:OFFLINE 
 Users      = How many users own objects in the tablespace 
 Size(MB)   = Total size of the tablespace 
 Used(MB)   = Total space occupied by objects in the tablespace 
 AW(MB)     = How much space is consumed by analytic workspaces in the tablespace 
 AW#        = Count of analytic workspaces in the tablepace 
 AWPts      = Count of partitions for analytic workspaces in the tablespace    
*/


set lines 150 pages 500 feedback off head on 
clear bre col comp buff 
col name        for a18         hea "Tablespace" 
col ownr        for 990         hea "Users" 
col ttype       for a1          hea "T|Y|P|E" 
col auto        for a1          hea "A|U|T|O" 
col segm        for a1          hea "S|E|G|M" 
col plg         for a1          hea "P|L|U|G" 
col lgg         for a1          hea "L|O|G|G" 
col status      for a1          hea "L|I|V|E" 
col sz          for 999,990.9   hea "Size(MB)" 
col usd         for 999,990.9   hea "Used(MB)" 
col awsz        for 999,990.9   hea "AW(MB)" 
col aws         for 990         hea "AW#" 
col segs        for 990         hea "AWPts"

bre on REPORT; 

comp sum lab total of aws  on REPORT; 
comp sum lab total of awsz on REPORT; 
comp sum lab total of fr   on REPORT; 
comp sum lab total of segs on REPORT; 
comp sum lab total of sz   on REPORT; 
comp sum lab total of usd  on REPORT; 

-- Uncomment the next line to create a view definition (optional) 
-- create or replace view aw_storage as 

SELECT d.tablespace_name name, substr(d.contents, 1, 1) ttype, 
  substr(a.autoextensible, 1, 1) auto, substr(d.segment_space_management, 1, 1) segm, 
  substr(d.plugged_in, 1, 1) plg, decode(d.logging,'LOGGING','Y','NOLOGGING','N','?') lgg, 
  decode(d.status, 'ONLINE', 'Y', 'OFFLINE', 'N', '?') status, 
  NVL(o.ownr,0) ownr, NVL(a.bytes/1024/1024,0) sz, 
  ((NVL(a.bytes/1024/1024,0))-(NVL(NVL(f.bytes,0),0)/1024/1024)) usd, 
  NVL(g.bytes/1024/1024,0) awsz, NVL(g.awcnt,0) aws, NVL(g.segcnt,0) segs 
FROM   sys.dba_tablespaces d, 
  (select tablespace_name, autoextensible, sum(bytes) bytes 
   from dba_data_files group by tablespace_name, autoextensible) a, 
  (select tablespace_name, sum(bytes) bytes from dba_free_space group by tablespace_name) f, 
  (select dbas.tablespace_name, count(distinct table_name) as awcnt, 
   count(*) as segcnt,  sum(dbas.bytes) bytes from dba_lobs dbal, dba_segments dbas 
   where dbal.column_name = 'AWLOB' and dbal.segment_name = dbas.segment_name 
   group by dbas.tablespace_name) g, 
  (select tablespace_name, count(distinct owner) ownr 
   from dba_segments group by tablespace_name) o 
WHERE  d.tablespace_name = a.tablespace_name(+) AND d.tablespace_name = f.tablespace_name(+) 
AND    d.tablespace_name = g.tablespace_name(+) AND d.tablespace_name = o.tablespace_name(+) 
AND    NOT (d.extent_management = 'LOCAL' AND d.contents = 'TEMPORARY') 
UNION ALL 
SELECT d.tablespace_name name, substr(d.contents, 1, 1) ttype, 
  substr(a.autoextensible, 1, 1) auto, substr(d.segment_space_management, 1, 1) segm, 
  substr(d.plugged_in, 1, 1) plg, decode(d.logging,'LOGGING','Y','NOLOGGING','N','?') lgg, 
  decode(d.status, 'ONLINE', 'Y', 'OFFLINE', 'N', '?') status, 
  NVL(o.ownr, 0) ownr, NVL(a.bytes /1024/1024, 0) sz, 
  ((NVL(a.bytes/1024/1024,0))-(NVL((a.bytes-t.bytes), a.bytes)/1024/1024)) usd, 
  NVL(g.bytes/1024/1024,0) awsz, NVL(g.awcnt,0) aws, NVL(g.segcnt,0) segs 
FROM   sys.dba_tablespaces d, 
  (select tablespace_name, autoextensible, sum(bytes) bytes 
   from dba_temp_files group by tablespace_name, autoextensible) a, 
  (select tablespace_name, sum(bytes_cached) bytes 
   from gv$temp_extent_pool group by tablespace_name) t, 
  (select dbas.tablespace_name, count(distinct table_name) as awcnt, 
   count(*) as segcnt, sum(dbas.bytes) bytes from dba_lobs dbal, dba_segments dbas 
   where dbal.column_name = 'AWLOB' and dbal.segment_name = dbas.segment_name 
   group by dbas.tablespace_name) g, 
  (select tablespace_name, count(distinct owner) ownr 
  from dba_segments group by tablespace_name) o 
WHERE  d.tablespace_name = a.tablespace_name(+) AND d.tablespace_name = t.tablespace_name(+) 
AND    d.tablespace_name = g.tablespace_name(+) AND d.tablespace_name = o.tablespace_name(+) 
AND    d.extent_management = 'LOCAL' AND d.contents = 'TEMPORARY' 
ORDER BY ttype, name; 


