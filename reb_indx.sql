--
--  Script : reb_indx.sql
--  Author : Marius RAICU
--  Purpose: rebuild the invalid indexes after ALTER TABLE xxx MOVE
--  For    : 8i+
--
-------------------------------------------------------------------------------------------

@save_sqlplus_settings

set lines 450 pages 0 head off trims on trim on
spool /tmp/rebuild_indx.sql
select 'alter index '||owner||'.'||index_name||' rebuild nologging storage(initial 16k next 16k minextents 1 maxextents unlimited pctincrease 0);' from dba_indexes
where owner not in ('SYS','SYSTEM','DBSNMP','OUTLN') and status!='VALID';
spool off
@/tmp/rebuild_indx.sql
host rm -f /tmp/rebuild_indx.sql

@restore_sqlplus_settings

