--
--  Script    : get_role.sql
--  Purpose   : extract role definition
--  Tested on : 10g,11g,12c,19c
--
@save_sqp_set

set head off autoprint off echo off show off tab off termout on newp none feed off lines 4096 long 5000000 longchunksize 30000
undef sch
accept sch char prompt 'Role? : ' default ''
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'PRETTY',true);
col sql_fulltext for a2048
spool /tmp/get_role.sql

SELECT
    dbms_metadata.get_ddl('ROLE',upper('&&sch')) AS sql_fulltext
FROM
    dba_roles r
WHERE
    r.role=upper('&&sch')
;

SELECT
    dbms_metadata.get_granted_ddl('ROLE_GRANT',upper('&&sch')) AS sql_fulltext
FROM
    dual
WHERE
    EXISTS(
        SELECT DISTINCT grantee
        FROM
            dba_role_privs
        WHERE
            grantee=upper('&&sch')
    )
;

SELECT
    dbms_metadata.get_granted_ddl('SYSTEM_GRANT',upper('&&sch')) AS sql_fulltext
FROM
    dual
WHERE
    EXISTS(
        SELECT DISTINCT grantee
        FROM
            dba_sys_privs
        WHERE
            grantee=upper('&&sch')
    )
;

SELECT
    dbms_metadata.get_granted_ddl('OBJECT_GRANT',upper('&&sch')) AS sql_fulltext
FROM
    dual
WHERE
    EXISTS(
        SELECT DISTINCT grantee
        FROM
            dba_tab_privs
        WHERE
            grantee=upper('&&sch')
    )
;

spool off
undef sch
@rest_sqp_set

exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'DEFAULT');
ed /tmp/get_role.sql