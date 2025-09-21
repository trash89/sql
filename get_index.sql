--
--  Script    : get_index.sql
--  Purpose   : extract indexes definition
--  Tested on : 10g,11g,12c,19c
--
@save_sqp_set

set head off autoprint off echo off show off tab off termout on newp none feed off lines 4096 long 5000000 longchunksize 30000
undef own
undef idx
undef tab
accept own char prompt 'Owner?(%)      : ' default ''
accept idx char prompt 'Index?(%)      : ' default ''
accept tab char prompt 'Table?(%)      : ' default ''
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'PRETTY',true);
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false);
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SEGMENT_ATTRIBUTES',false);
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'CONSTRAINTS_AS_ALTER',true);
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'REF_CONSTRAINTS',true);
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SIZE_BYTE_KEYWORD',false);
col sql_fulltext for a2048
spool /tmp/get_index.sql
SELECT
    dbms_metadata.get_ddl('INDEX',i.index_name,i.owner) sql_fulltext
FROM
    dba_indexes i
WHERE
    i.owner LIKE upper('%&&own%')
    AND i.table_name LIKE '%'||upper(substr('&&tab%',instr('&&tab%','.')+1))                
    AND i.index_name LIKE '%'||upper(substr('&&idx%',instr('&&idx%','.')+1))                    
;
spool off
undef own
undef idx
undef tab

@rest_sqp_set

exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'DEFAULT');
ed /tmp/get_index.sql