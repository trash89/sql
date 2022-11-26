set lines 150 pages 200
column segment_name format a20
column kilo format 999999999.99
column table_name format a20
column pfree format 99
column pused format 99
column inie format 999999999
column nexte format 999999999
column mine format 999999999
column maxe format 999999999999
column pinc format 999999999
column tablespace_name format a20
column minel format 999999999.99
break on segment_name
compute sum of kilo on segment_name
select segment_name,bytes/1024 as kilo,blocks from dba_extents where owner not in ('SYS','SYSTEM','DBSNMP');
clear computes
select table_name,
       pct_free pfree,
       pct_used pused,
       initial_extent inie,
       next_extent nexte,
       min_extents mine,
       max_extents maxe,
       pct_increase pinc
from dba_tables where owner not in ('SYS','SYSTEM','DBSNMP');
select tablespace_name,
       initial_extent inie,
       next_extent nexte,
       min_extents mine,
       max_extents maxe,
       pct_increase pinc,
       min_extlen minel
from dba_tablespaces;
clear columns

