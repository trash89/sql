--
--  Script    : get_table.sql
--  Purpose   : extract tables/matvlogs/indexes/triggers/sequences definition
--  Tested on : 10g,11g,12c,19c
--
@save_sqp_set

set head off autoprint off echo off show off tab off termout on newp none feed off lines 4096 long 5000000 longchunksize 30000
undef own
undef tab
accept own char prompt 'Owner?(%)      : ' default ''
accept tab char prompt 'Table?(%)      : ' default ''
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'PRETTY',true);
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false);
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SEGMENT_ATTRIBUTES',false);
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'CONSTRAINTS_AS_ALTER',true);
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'REF_CONSTRAINTS',true);
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SIZE_BYTE_KEYWORD',false);
col sql_fulltext for a2048
spool /tmp/get_table.sql
SELECT
    dbms_metadata.get_ddl('TABLE',u.table_name,u.owner) as sql_fulltext
FROM
    dba_tables u
WHERE
    u.owner LIKE upper('%&&own%')
    AND u.table_name LIKE '%'||upper(substr('&&tab%',instr('&&tab%','.')+1))
    AND u.nested='NO'
    AND (u.iot_type IS NULL OR u.iot_type='IOT')
;

SELECT
    dbms_metadata.get_dependent_ddl('MATERIALIZED_VIEW_LOG',u.master,u.log_owner) as sql_fulltext
FROM
    dba_mview_logs u
WHERE
    u.log_owner LIKE upper('%&&own%')
    AND u.master LIKE '%'||upper(substr('&&tab%',instr('&&tab%','.')+1))    
;

SELECT
    dbms_metadata.get_ddl('SEQUENCE',u.sequence_name,u.sequence_owner) as sql_fulltext
FROM
    dba_sequences u
WHERE
    u.sequence_owner LIKE upper('%&&own%')
    AND u.sequence_name LIKE '%'||upper(substr('&&tab%',instr('&&tab%','.')+1))    
;

SELECT
    dbms_metadata.get_dependent_ddl('INDEX',u.table_name,u.owner) as sql_fulltext
FROM
    dba_tables  u
WHERE
    u.owner LIKE upper('%&&own%')
    AND u.table_name LIKE '%'||upper(substr('&&tab%',instr('&&tab%','.')+1))
    AND u.nested='NO'
    AND (u.iot_type IS NULL OR u.iot_type='IOT')
    AND EXISTS(
        SELECT table_name FROM dba_indexes i
        WHERE
            i.table_name=u.table_name
            AND i.owner=u.owner
    )
;

SELECT
    dbms_metadata.get_dependent_ddl('TRIGGER',u.table_name,u.owner) as sql_fulltext
FROM
    (
        SELECT DISTINCT owner,table_owner,table_name
        FROM
            dba_triggers t
        WHERE
            t.owner LIKE upper('%&&own%')
            AND t.table_name LIKE '%'||upper(substr('&&tab%',instr('&&tab%','.')+1))            
    ) u
;

SELECT
    dbms_metadata.get_dependent_ddl('OBJECT_GRANT',u.table_name,u.owner) as sql_fulltext
FROM
    dba_tab_privs u
WHERE
    u.owner LIKE upper('%&&own%')
    AND u.table_name LIKE '%'||upper(substr('&&tab%',instr('&&tab%','.')+1))    
;

spool off
undef own
undef tab

@rest_sqp_set

exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'DEFAULT');
ed /tmp/get_table.sql