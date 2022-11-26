set lines 150 pages 200 feed on
column owner format a15
column index_owner format a15
column index_name format a25
column partition_name format a15
column object_name format a40
column object_type format a25
column status format a10
select 
     owner,object_name,object_type,status 
from 
     dba_objects 
where 
     status!='VALID'
union all
select 
     owner,index_name,'',status 
from 
     dba_indexes 
where 
     status not in ('VALID','N/A')
union all
select 
     index_owner,index_name,partition_name,status 
from 
     dba_ind_partitions 
where 
     status not in ('USABLE','VALID','N/A');

clear columns
set lines 200 pages 24
