set feedback off;
set feedback off;
set lines 200 pages 0;
define _editor=vi;
set sqlprompt "&_user@&_CONNECT_IDENTIFIER> ";
alter session set NLS_LANGUAGE='AMERICAN' NLS_TERRITORY='AMERICA';
alter session set NLS_CURRENCY='$' NLS_ISO_CURRENCY='AMERICA' NLS_NUMERIC_CHARACTERS='.,';
alter session set NLS_DATE_LANGUAGE='AMERICAN' NLS_COMP='BINARY' NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS';

SELECT '*********** Current connection details ***********' FROM DUAL
UNION ALL
--SELECT 'Starting: '|| SYSDATE FROM DUAL
--UNION ALL
--SELECT 'Language: '||SYS_CONTEXT('USERENV', 'LANGUAGE') FROM DUAL
--UNION ALL
--SELECT 'SID     : '||SYS_CONTEXT('USERENV', 'SID') FROM DUAL
--UNION ALL
SELECT 'DB user : '||SYS_CONTEXT('USERENV', 'SESSION_USER') FROM DUAL
UNION ALL
SELECT 'Instance: '||SYS_CONTEXT('USERENV', 'INSTANCE_NAME') FROM DUAL
UNION ALL
SELECT 'Server  : '||SYS_CONTEXT('USERENV', 'SERVER_HOST') FROM DUAL
UNION ALL
SELECT 'Database: '||SYS_CONTEXT('USERENV', 'DB_UNIQUE_NAME') FROM DUAL
UNION ALL
SELECT '*********** Current connection details ***********' FROM DUAL;

set pages 500;
set feedback on;
set timing on;
