set lines 200 pages 22 head off feed off
spool /tmp/tabreb.sql
select 'alter table '||owner||'.'||segment_name||' move pctfree 5 pctused 90 initrans 8 maxtrans 128 storage(initial 16K next 16K minextents 1 freelists 1);' from dba_segments 
where segment_type='TABLE' and owner not in ('SYS','SYSTEM','DBSNMP','OUTLN','RMAN','PERFSTAT');
spool off
set lines 150 pages 22 head on feed on
pause
@@/tmp/tabreb.sql
host rm /tmp/tabreb.sql
