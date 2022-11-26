--
--  Script : x.sql
--  Purpose: Show some informations from the X$ tables needed for tuning
--  Author : Marius RAICU
--  For    : 8.1
---------------------------------------------------------------------------
@save_sqlplus_settings

set term off
column inst noprint new_value inst
select 'x_'||i.instance_name||'_'||i.host_name||'_'||to_char(sysdate,'dd_mm_rrrr_hh24_mi')||'.lst' as inst from v$instance i
where i.instance_number=userenv('instance');

set term on
spool &&inst
set lines 80 pages 200 head on feed off

prompt From X$KSQST
select ksqsttyp as eq_type,
       ksqstget as gets,
       ksqstwat as waits
from x$ksqst
where ksqstget!=0
order by 2;

prompt From X$KCBFWAIT
select * from x$kcbfwait where count!=0 or time!=0;

set lines 110
column owner format a15
column object_name format a35
column object_type format a15

prompt From X$BH
select ob.owner,ob.object_name,ob.object_type,ob.owner,bh.ct
from (
      select /*+ no_merge */ obj,count(*) ct
      from x$bh
      group by obj
      having count(*)>100
     ) bh, 
    dba_objects ob
where ob.data_object_id=bh.obj 
      and ob.owner not in ('SYS','SYSTEM');
spool off
set lines 80 pages 22 feed on

@restore_sqlplus_settings

