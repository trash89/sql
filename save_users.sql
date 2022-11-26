set lines 150 pages 0
spool /tmp/save_users.sql
select 'create user '||username||' identified by values '||chr(39)||password||chr(39)||' default tablespace '||default_tablespace||' temporary tablespace '||temporary_tablespace||';' from dba_users order by username;

prompt dba_sys_privs
SELECT 'grant '||privilege||' to '||grantee||decode(admin_option,'YES',' with admin option;',';') as "SYS privs" FROM dba_sys_privs where grantee not in ('CONNECT','SYSTEM','OLAPSYS','XDB','RESOURCE','SYS','OLAP_USER','EXP_FULL_DATABASE','TSMSYS','RECOVERY_CATALOG_OWNER','SYSMAN','ANONYMOUS','SCHEDULER_ADMIN','EXFSYS','AQ_ADMINISTRATOR_ROLE','OPS$ORACLE','OEM_ADVISOR','OLAP_DBA','DBA','IMP_FULL_DATABASE','MGMT_USER','CTXSYS','JAVADEBUGPRIV','OEM_MONITOR','DBSNMP','DMSYS','OUTLN') and grantee not in (select role from dba_roles) order by grantee,privilege;


prompt dba_role_privs
SELECT 'grant '||GRANTED_ROLE||' to '||grantee||decode(admin_option,'YES',' with admin option;',';') as "ROLE privs" FROM dba_role_privs where grantee not in ('CONNECT','SYSTEM','OLAPSYS','XDB','RESOURCE','SYS','OLAP_USER','EXP_FULL_DATABASE','TSMSYS','RECOVERY_CATALOG_OWNER','SYSMAN','ANONYMOUS','SCHEDULER_ADMIN','EXFSYS','AQ_ADMINISTRATOR_ROLE','OPS$ORACLE','OEM_ADVISOR','OLAP_DBA','DBA','IMP_FULL_DATABASE','MGMT_USER','CTXSYS','JAVADEBUGPRIV','OEM_MONITOR','DBSNMP','DMSYS','OUTLN') order by grantee,granted_role;

/*
prompt dba_tab_privs
SELECT GRANTEE,OWNER,TABLE_NAME,GRANTOR,PRIVILEGE,GRANTABLE,HIERARCHY FROM dba_tab_privs order by 1,2,3,4,5;


prompt dba_ts_quotas
SELECT * FROM dba_ts_quotas WHERE username='CCT_ADM';
*/

spool off
set lines 150 pages 22

