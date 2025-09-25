--
--  Script    : users.sql
--  Purpose   : show the users in the database
--  Tested on : 11g,12c,19c,23c
--
@save_sqp_set

set lines 165 pages 50
col username                for a30
col account_status          for a20
col default_tablespace      for a25 head 'Default TBS'
col temporary_tablespace    for a25 head 'Temp TBS'
col createdc                for a20 head 'Created'
col password_versions       for a17 head 'PwdVers'
col oracle_maintained       for a7  head 'OraMnt'
ttitle left 'dba_users'
SELECT * FROM (
SELECT
    username
   ,account_status
   ,default_tablespace
   ,temporary_tablespace
   ,to_char(created,'dd/mm/yyyy hh24:mi:ss') as createdc
   ,password_versions
   ,'Y' as oracle_maintained
FROM
    dba_users
WHERE
    username IN (
            'SYS','SYSTEM','DMSYS','EXFSYS','MGMT_VIEW','SYSMAN','TSMSYS','APEX_030200','APEX_PUBLIC_USER','FLOWS_FILES','OWBSYS','OWBSYS_AUDIT',
            'SPATIAL_WFS_ADMIN_USR','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DIP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL',
            'GSMCATUSER','GSMUSER','GSMROOTUSER','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN',
            'REMOTE_SCHEDULER_AGENT','SI_INFORMTN_SCHEMA','SYS$UMF','SYSBACKUP','SYSDG','SYSKM','SYSRAC','WMSYS','XDB','XS$NULL','SPATIAL_CSW_ADMIN_USR'
            )
union all
SELECT
    username
   ,account_status
   ,default_tablespace
   ,temporary_tablespace
   ,to_char(created,'dd/mm/yyyy hh24:mi:ss') as createdc
   ,password_versions
   ,'N' as oracle_maintained
FROM
    dba_users
WHERE
    username not IN (
            'SYS','SYSTEM','DMSYS','EXFSYS','MGMT_VIEW','SYSMAN','TSMSYS','APEX_030200','APEX_PUBLIC_USER','FLOWS_FILES','OWBSYS','OWBSYS_AUDIT',
            'SPATIAL_WFS_ADMIN_USR','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DIP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL',
            'GSMCATUSER','GSMUSER','GSMROOTUSER','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN',
            'REMOTE_SCHEDULER_AGENT','SI_INFORMTN_SCHEMA','SYS$UMF','SYSBACKUP','SYSDG','SYSKM','SYSRAC','WMSYS','XDB','XS$NULL','SPATIAL_CSW_ADMIN_USR'
            )
)    
ORDER BY
     oracle_maintained DESC
    ,username
;

@rest_sqp_set
