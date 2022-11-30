set SPACE 0
set PAGES 1000
set LINESIZE 200
set LONG 1000
set TERMOUT ON
set ECHO ON
col parameter for a25
col value for a30
col owner for a30
col table_name for a30
spool NLSUnix.txt
select * from NLS_SESSION_PARAMETERS;
select * from NLS_INSTANCE_PARAMETERS;
select * from NLS_DATABASE_PARAMETERS;
select * from V$NLS_PARAMETERS;
select NAME, VALUE$ from SYS.PROPS$;
select to_char(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') from DUAL;
select SESSIONTIMEZONE from DUAL;
select DBTIMEZONE from DUAL;
select distinct OWNER, TABLE_NAME from DBA_TAB_COLUMNS where DATA_TYPE in ('NCHAR','NVARCHAR2', 'NCLOB');
-- select distinct(nls_charset_name(charsetid)) CHARACTERSET,
-- decode(type#, 1, decode(charsetform, 1, 'VARCHAR2', 2, 'NVARCHAR2','UNKOWN'),
-- 9, decode(charsetform, 1, 'VARCHAR', 2, 'NCHAR VARYING', 'UNKOWN'),
-- 96, decode(charsetform, 1, 'CHAR', 2, 'NCHAR', 'UNKOWN'),
-- 112, decode(charsetform, 1, 'CLOB', 2, 'NCLOB', 'UNKOWN')) TYPES_USED_IN
-- from sys.col$ where charsetform in (1,2) and type# in (1, 9, 96, 112);
select unique VALUE from V$NLS_VALID_VALUES where PARAMETER ='CHARACTERSET';
select unique VALUE from V$NLS_VALID_VALUES where PARAMETER ='LANGUAGE';
select unique VALUE from V$NLS_VALID_VALUES where PARAMETER ='SORT';
select unique VALUE from V$NLS_VALID_VALUES where PARAMETER ='TERRITORY';
select OSUSER, PROCESS, MACHINE, TERMINAL, PROGRAM, MODULE, MODULE_HASH, CLIENT_INFO from V$SESSION where SCHEMANAME = user;
select OWNER, TRIGGER_NAME, TRIGGER_BODY from DBA_TRIGGERS where trim(TRIGGERING_EVENT) = 'LOGON';
spool OFF
HOST echo 'NLS_LANG setting:' >> NLSUnix.txt
HOST echo $NLS_LANG >> NLSUnix.txt
HOST echo 'locale settings:' >> NLSUnix.txt
HOST locale >> NLSUnix.txt
HOST echo 'Environment LANG, LC, TZ, NLS and ORA settings:' >> NLSUnix.txt
HOST env | egrep 'LANG|LC_|TZ|NLS|ORA' >> NLSUnix.txt
HOST echo 'unix time:' >> NLSUnix.txt
HOST date >> NLSUnix.txt 

