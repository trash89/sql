prompt Regenerating snapshots
set termout on heading off feedback off pagesize 0 lines 200
spool /tmp/cp1.sql
select 'exec dbms_repcat.generate_snapshot_support('||chr(39)||owner||chr(39)||','||chr(39)||name||chr(39)||','||chr(39)||'SNAPSHOT'||chr(39)||');' from dba_snapshots
where updatable='YES';
spool off
set termout on heading on feedback on pagesize 22 echo on
@/tmp/cp1.sql
host rm -f /tmp/cp1.sql /tmp/cp2.sql
set echo off
