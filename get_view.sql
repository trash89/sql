--
--  Script    : get_view.sql
--  Purpose   : extract view definition
--  Tested on : 10g,11g,12c,19c
--
@save_sqp_set

set head off autoprint off echo off show off tab off termout on newp none feed off lines 4096 long 5000000 longchunksize 30000
undef own
undef tab
accept own char prompt 'Owner?(%)  : ' default ''
accept tab char prompt 'View?(%)   : ' default ''
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'PRETTY',true);
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);
col sql_fulltext for a2048
spool /tmp/get_view.sql
SELECT 
    dbms_metadata.get_ddl('VIEW',u.view_name,u.owner) as sql_fulltext
FROM 
    dba_views u
WHERE
    u.owner LIKE upper('%&&own%')
    AND u.view_name LIKE '%'||upper(substr('&&tab%',instr('&&tab%','.')+1))                
;
spool off
undef own
undef tab

@rest_sqp_set

exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'DEFAULT');
ed /tmp/get_view.sql