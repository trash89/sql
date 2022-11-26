prompt Compiling INVALID objects
set termout off heading off feedback off pagesize 0 lines 200
spool /tmp/cp1.sql
select 'ALTER '||object_type||' '||owner||'.'||object_name||' COMPILE;' from dba_objects where status='INVALID' and object_type not in ('PACKAGE BODY','TYPE BODY','JAVA CLASS');
spool off
spool /tmp/cp2.sql
select 'ALTER PACKAGE '||owner||'.'||object_name||' COMPILE BODY;' from dba_objects where status='INVALID' and object_type='PACKAGE BODY';
spool off
spool /tmp/cp3.sql
select 'ALTER public synonym '||object_name||' COMPILE;' from dba_objects where status='INVALID' and object_type='SYNONYM' and owner='PUBLIC';
spool off

set termout on heading on feedback on pagesize 22 echo on
@/tmp/cp2.sql
@/tmp/cp1.sql
@/tmp/cp3.sql
host rm -f /tmp/cp1.sql /tmp/cp2.sql /tmp/cp3.sql
set echo off
