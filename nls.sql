--
--  Script    : nls.sql
--  Purpose   : extract nls informations
--  Tested on : 8i+ 
--
@save_sqp_set

set lines 200 pages 0 long 1000 termout on
col parameter   for a30
col name        for a50
col value       for a64


col owner       for a30
col table_name  for a30

spool /tmp/NLSUnix.txt
prompt 'nls_session_parameters'
SELECT
    *
FROM
    nls_session_parameters
;

prompt 'nls_instance_parameters'
SELECT
    *
FROM
    nls_instance_parameters
;

prompt 'nls_database_parameters'
SELECT
    *
FROM
    nls_database_parameters
;

prompt 'v$nls_parameters'
SELECT
     parameter
    ,value
FROM
    gv$nls_parameters
WHERE    
    inst_id=to_number(sys_context('USERENV','INSTANCE'))    
;

prompt 'sys.props$'
SELECT
    name
   ,value$ as value
FROM
    sys.props$
;

prompt 'current date'
SELECT
    to_char(sysdate,'DD/MM/YYYY HH24:MI:SS') as current_date
FROM
    dual
;

prompt 'sessiontimezone'
SELECT
    sessiontimezone
FROM
    dual
;

prompt 'dbtimezone'
SELECT
    dbtimezone
FROM
    dual
;

prompt 'dba_tab_columns'
SELECT
    DISTINCT owner
   ,table_name
FROM
    dba_tab_columns
WHERE
    data_type IN('NCHAR','NVARCHAR2','NCLOB')
    AND owner not in ('SYS','SYSTEM','DMSYS','EXFSYS','MGMT_VIEW','SYSMAN','TSMSYS','APEX_030200','APEX_PUBLIC_USER','FLOWS_FILES','OWBSYS','OWBSYS_AUDIT','SPATIAL_WFS_ADMIN_USR','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DIP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','GSMCATUSER','GSMUSER','GSMROOTUSER','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','REMOTE_SCHEDULER_AGENT','SI_INFORMTN_SCHEMA','SYS$UMF','SYSBACKUP','SYSDG','SYSKM','SYSRAC','WMSYS','XDB','XS$NULL','SPATIAL_CSW_ADMIN_USR')
;
-- SELECT DISTINCT(nls_charset_name(charsetid)) CHARACTERSET,
-- decode(type#, 1, decode(charsetform, 1, 'VARCHAR2', 2, 'NVARCHAR2','UNKOWN'),
-- 9, decode(charsetform, 1, 'VARCHAR', 2, 'NCHAR VARYING', 'UNKOWN'),
-- 96, decode(charsetform, 1, 'CHAR', 2, 'NCHAR', 'UNKOWN'),
-- 112, decode(charsetform, 1, 'CLOB', 2, 'NCLOB', 'UNKOWN')) TYPES_USED_IN
-- FROM sys.col$ WHERE charsetform in (1,2) AND type# in (1, 9, 96, 112);
prompt 'v$nls_valid_values CHARACTERSET'
SELECT
    UNIQUE value
FROM
    gv$nls_valid_values
WHERE
    parameter in ('CHARACTERSET')
    AND inst_id=to_number(sys_context('USERENV','INSTANCE'))
ORDER BY 
    1
;

prompt 'v$nls_valid_values LANGUAGE'
SELECT
    UNIQUE value
FROM
    gv$nls_valid_values
WHERE
    parameter in ('LANGUAGE')
    AND inst_id=to_number(sys_context('USERENV','INSTANCE'))        
ORDER BY 
    1    
;

prompt 'v$nls_valid_values SORT'
SELECT
    UNIQUE value
FROM
    gv$nls_valid_values
WHERE
    parameter in ('SORT')
    AND inst_id=to_number(sys_context('USERENV','INSTANCE'))        
ORDER BY 
    1    
;

prompt 'v$nls_valid_values TERRITORY'
SELECT
    UNIQUE value
FROM
    gv$nls_valid_values
WHERE
    parameter in ('TERRITORY')
    AND inst_id=to_number(sys_context('USERENV','INSTANCE'))        
ORDER BY 1    
;

prompt 'dba_triggers LOGON'
SELECT
    owner
   ,trigger_name
   ,trigger_body
FROM
    dba_triggers
WHERE
    trim(triggering_event)='LOGON'
;

spool OFF
HOST echo 'NLS_LANG setting:'>>/tmp/NLSUnix.txt
HOST echo $NLS_LANG>>/tmp/NLSUnix.txt
HOST echo 'locale settings:'>>/tmp/NLSUnix.txt
HOST locale|sort>>/tmp/NLSUnix.txt
HOST echo 'Environment LANG, LC, TZ, NLS AND ORA settings:'>>/tmp/NLSUnix.txt
HOST env|egrep 'LANG|LC_|TZ|NLS|ORA'|sort>>/tmp/NLSUnix.txt
HOST echo 'unix time:'>>/tmp/NLSUnix.txt
HOST date>>/tmp/NLSUnix.txt

@rest_sqp_set

ed /tmp/NLSUnix.txt