undef sch
accept sch char prompt 'Schema?:' default ''
SET long 200000000
EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);
SELECT dbms_metadata.get_ddl('USER',upper('&&sch')) FROM dual;
SELECT DBMS_METADATA.GET_DEPENDENT_DDL('OBJECT_GRANT', object_name, 'KIRAND') INTO object_MD FROM DUAL;

undef sch