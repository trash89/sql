SET LONG 2000000 PAGESIZE 0 lines 200

EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'PRETTY',true);
EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false);
EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);
EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SEGMENT_ATTRIBUTES',false);
EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'CONSTRAINTS_AS_ALTER',true);
EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'REF_CONSTRAINTS',true);
EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SIZE_BYTE_KEYWORD',true);

spool /tmp/get_tables.sql

SELECT DBMS_METADATA.GET_DDL('TABLE',u.table_name) as create_tables FROM USER_ALL_TABLES u WHERE u.nested='NO' AND (u.iot_type is null or u.iot_type='IOT')
union all
select DBMS_METADATA.GET_DEPENDENT_DDL('INDEX', u.table_name) create_indexes FROM USER_ALL_TABLES u WHERE u.nested='NO' AND (u.iot_type is null or u.iot_type='IOT') and u.table_name in (select distinct table_name from user_indexes where index_type='NORMAL')
union all
select DBMS_METADATA.GET_DEPENDENT_DDL('TRIGGER', u.table_name) as create_triggers FROM (select distinct table_name from user_triggers) u;

spool off
EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'DEFAULT');
ed /tmp/get_tables.sql
