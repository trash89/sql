---------------------------------------------     APP    -----------------------------------------

/*
prompt Count all tables
select table_name,to_number(extractvalue(xmltype(dbms_xmlgen.getxml('select count(*) c from '||table_name)),'/ROWSET/ROW/C')) count from user_tables;
*/



/*
compute sum of cnt label 'Total' on report
prompt
prompt Public synonyms by table owner
select table_owner,count(*) cnt from dba_synonyms 
  where owner='PUBLIC' and table_owner not in ('SYS','SYSTEM','OUTLN','DBSNMP','CTXSYS','DRSYS','MDSYS','ORDSYS','ORDPLUGINS','TRACESVR','AURORA$JIS$UTILITY$','AURORA$ORB$UNAUTHENTICATED','LBACSYS','OLAPDBA','OLAPSVR','OLAPSYS','OSE$HTTP$ADMIN','WKSYS','XDB','WMSYS','WK_TEST','WK_PROXY','SYSMAN','SI_INFORMTN_SCHEMA','SCOTT','MGMT_VIEW','MDDATA','EXFSYS','DMSYS','ANONYMOUS','BC4J','FLOWS_020000','FLOWS_FILES','OPS$ORACLE','OWBRT10GR1_REF','OWF_MGR','D4OSYS','CSMIG','ADMINBO','ADMINBOXI','OWBRT_SYS','TSMSYS','AUDITBOXI') 
group by table_owner order by 1;
clear computes 
clear breaks
*/


/*
prompt
prompt Public db links 
select username,db_link from dba_db_links where owner='PUBLIC'
order by 1;
clear computes 
clear breaks
*/


/*
prompt Directories
set lines 500 pages 200
col owner for a5
col directory_name for a25
col directory_path for a200
select owner,directory_name,directory_path from dba_directories order by 1,2;
clear columns
*/


/*
prompt DBA_RECYCLEBIN
select owner,count(*) from dba_recyclebin where owner not in ('SYS','SYSTEM') group by owner order by 1;
*/


/*
prompt Contexts
select * from dba_context where schema not in ('SYS','SYSMAN','CTXSYS') order by 2,1,3,4;
*/


/*
prompt Policies
col object_owner for a12
col object_name for a30
col policy_group for a15
col policy_name for a30
col pf_owner for a12
col package for a20
col function for a25
col policy_type for a11
col static_policy for a10 head "StaticPol"
col long_predicate for a10 head "LongPred"
select * from dba_policies where object_owner not in ('SYS','XDB') order by 1,2;
clear columns
*/


/*
prompt Profiles
select * from dba_profiles order by 1,2;
*/


/*
Prompt Audit Trail
select count(*) from dba_common_audit_trail;
prompt Audit Session
select count(*) from dba_audit_session;
prompt Audit object
select count(*) from dba_audit_object;
*/



/*
prompt Roles
select * from dba_roles where role not in ('CONNECT','RESOURCE','DBA','SELECT_CATALOG_ROLE','EXECUTE_CATALOG_ROLE','DELETE_CATALOG_ROLE',
  'EXP_FULL_DATABASE','IMP_FULL_DATABASE','RECOVERY_CATALOG_OWNER','GATHER_SYSTEM_STATISTICS','LOGSTDBY_ADMINISTRATOR','AQ_ADMINISTRATOR_ROLE',
  'AQ_USER_ROLE','GLOBAL_AQ_USER_ROLE','SCHEDULER_ADMIN','HS_ADMIN_ROLE','OEM_ADVISOR','OEM_MONITOR','JAVAUSERPRIV','JAVAIDPRIV','JAVASYSPRIV',
  'JAVADEBUGPRIV','EJBCLIENT','JAVA_ADMIN','JAVA_DEPLOY','MGMT_USER','XDBADMIN','AUTHENTICATEDUSER','XDBWEBSERVICES','ORA_USER_CONNECT',
  'ORA_USER_RESOURCE','ORA_APPLI','OLAP_USER','WF_PLSQL_UI','WB_U_OWBRT10GR1_REF','OLAP_DBA','WB_D_OWBRT10GR1_REF','WB_R_OWBRT10GR1_REF',
  'WB_A_OWBRT10GR1_REF','D4OPUB','CTXAPP','WKUSER','WM_ADMIN_ROLE'
  ) order by 1;
*/




/*
break on owner skip 1
prompt
prompt object_types 
select object_type,count(*) cnt from dba_objects 
  where owner not in ('SYS','SYSTEM','OUTLN','DBSNMP','CTXSYS','DRSYS','MDSYS','ORDSYS','ORDPLUGINS','TRACESVR','AURORA$JIS$UTILITY$','AURORA$ORB$UNAUTHENTICATED','LBACSYS','OLAPDBA','OLAPSVR','OLAPSYS','OSE$HTTP$ADMIN','WKSYS','XDB','WMSYS','WK_TEST','WK_PROXY','SYSMAN','SI_INFORMTN_SCHEMA','SCOTT','MGMT_VIEW','MDDATA','EXFSYS','DMSYS','ANONYMOUS','BC4J','FLOWS_020000','FLOWS_FILES','OPS$ORACLE','OWBRT10GR1_REF','OWF_MGR','D4OSYS','CSMIG','PUBLIC','ADMINBO','ADMINBOXI','OWBRT_SYS','TSMSYS','AUDITBOXI') 
 and object_name not in (select object_name from dba_recyclebin)
group by rollup(object_type) order by 1;
clear breaks
clear computes
*/



/*
break on owner skip 1
compute sum of cnt label 'Total' on owner
prompt
prompt object_types for specific owner
select owner,object_type,count(*) cnt from dba_objects 
  where owner not in ('SYS','SYSTEM','OUTLN','DBSNMP','CTXSYS','DRSYS','MDSYS','ORDSYS','ORDPLUGINS','TRACESVR','AURORA$JIS$UTILITY$','AURORA$ORB$UNAUTHENTICATED','LBACSYS','OLAPDBA','OLAPSVR','OLAPSYS','OSE$HTTP$ADMIN','WKSYS','XDB','WMSYS','WK_TEST','WK_PROXY','SYSMAN','SI_INFORMTN_SCHEMA','SCOTT','MGMT_VIEW','MDDATA','EXFSYS','DMSYS','ANONYMOUS','BC4J','FLOWS_020000','FLOWS_FILES','OPS$ORACLE','OWBRT10GR1_REF','OWF_MGR','D4OSYS','CSMIG','PUBLIC','ADMINBO','ADMINBOXI','OWBRT_SYS','TSMSYS','AUDITBOXI') 
        and owner like '%_OWN' and object_name not in (select object_name from dba_recyclebin)
group by owner,object_type order by 1,2;
clear breaks
clear computes
*/




/*
prompt
Prompt Database links by base
set lines 500 pages 200
col owner for a15
col db_link for a55
col username for a15
col host for a200
select OWNER,DB_LINK,USERNAME,HOST from dba_db_links order by 1,2,3;
clear columns
clear breaks
*/



/*
prompt
prompt Functions by owner
select owner,object_type,count(*) cnt from dba_objects 
  where owner not in ('SYS','SYSTEM','OUTLN','DBSNMP','CTXSYS','DRSYS','MDSYS','ORDSYS','ORDPLUGINS','TRACESVR','AURORA$JIS$UTILITY$','AURORA$ORB$UNAUTHENTICATED','LBACSYS','OLAPDBA','OLAPSVR','OLAPSYS','OSE$HTTP$ADMIN','WKSYS','XDB','WMSYS','WK_TEST','WK_PROXY','SYSMAN','SI_INFORMTN_SCHEMA','SCOTT','MGMT_VIEW','MDDATA','EXFSYS','DMSYS','ANONYMOUS','BC4J','FLOWS_020000','FLOWS_FILES','OPS$ORACLE','OWBRT10GR1_REF','OWF_MGR','D4OSYS','CSMIG','PUBLIC','ADMINBO','ADMINBOXI','OWBRT_SYS','TSMSYS','AUDITBOXI') 
      and object_type='FUNCTION' and object_name not in (select object_name from dba_recyclebin)
group by owner,object_type order by 1;
clear breaks
clear computes
*/

/*
prompt
prompt Procedures by owner
select owner,object_type,count(*) cnt from dba_objects 
  where owner not in ('SYS','SYSTEM','OUTLN','DBSNMP','CTXSYS','DRSYS','MDSYS','ORDSYS','ORDPLUGINS','TRACESVR','AURORA$JIS$UTILITY$','AURORA$ORB$UNAUTHENTICATED','LBACSYS','OLAPDBA','OLAPSVR','OLAPSYS','OSE$HTTP$ADMIN','WKSYS','XDB','WMSYS','WK_TEST','WK_PROXY','SYSMAN','SI_INFORMTN_SCHEMA','SCOTT','MGMT_VIEW','MDDATA','EXFSYS','DMSYS','ANONYMOUS','BC4J','FLOWS_020000','FLOWS_FILES','OPS$ORACLE','OWBRT10GR1_REF','OWF_MGR','D4OSYS','CSMIG','PUBLIC','ADMINBO','ADMINBOXI','OWBRT_SYS','TSMSYS','AUDITBOXI') 
      and object_type='PROCEDURE' and object_name not in (select object_name from dba_recyclebin)
group by owner,object_type order by 1;
clear breaks
clear computes
*/


/*
prompt
prompt Packages by owner
select owner,object_type,count(*) cnt from dba_objects 
  where owner not in ('SYS','SYSTEM','OUTLN','DBSNMP','CTXSYS','DRSYS','MDSYS','ORDSYS','ORDPLUGINS','TRACESVR','AURORA$JIS$UTILITY$','AURORA$ORB$UNAUTHENTICATED','LBACSYS','OLAPDBA','OLAPSVR','OLAPSYS','OSE$HTTP$ADMIN','WKSYS','XDB','WMSYS','WK_TEST','WK_PROXY','SYSMAN','SI_INFORMTN_SCHEMA','SCOTT','MGMT_VIEW','MDDATA','EXFSYS','DMSYS','ANONYMOUS','BC4J','FLOWS_020000','FLOWS_FILES','OPS$ORACLE','OWBRT10GR1_REF','OWF_MGR','D4OSYS','CSMIG','PUBLIC','ADMINBO','ADMINBOXI','OWBRT_SYS','TSMSYS','AUDITBOXI') 
      and object_type='PACKAGE' and object_name not in (select object_name from dba_recyclebin)
group by owner,object_type order by 1;
clear breaks
clear computes
*/

/*
prompt
prompt Triggers by owner
select owner,object_type,count(*) cnt from dba_objects 
  where owner not in ('SYS','SYSTEM','OUTLN','DBSNMP','CTXSYS','DRSYS','MDSYS','ORDSYS','ORDPLUGINS','TRACESVR','AURORA$JIS$UTILITY$','AURORA$ORB$UNAUTHENTICATED','LBACSYS','OLAPDBA','OLAPSVR','OLAPSYS','OSE$HTTP$ADMIN','WKSYS','XDB','WMSYS','WK_TEST','WK_PROXY','SYSMAN','SI_INFORMTN_SCHEMA','SCOTT','MGMT_VIEW','MDDATA','EXFSYS','DMSYS','ANONYMOUS','BC4J','FLOWS_020000','FLOWS_FILES','OPS$ORACLE','OWBRT10GR1_REF','OWF_MGR','D4OSYS','CSMIG','PUBLIC','ADMINBO','ADMINBOXI','OWBRT_SYS','TSMSYS','AUDITBOXI') 
      and object_type='TRIGGER' and object_name not in (select object_name from dba_recyclebin)
group by owner,object_type order by 1;
clear breaks
clear computes
*/

/*
prompt
prompt Types by owner
select owner,object_type,count(*) cnt from dba_objects 
  where owner not in ('SYS','SYSTEM','OUTLN','DBSNMP','CTXSYS','DRSYS','MDSYS','ORDSYS','ORDPLUGINS','TRACESVR','AURORA$JIS$UTILITY$','AURORA$ORB$UNAUTHENTICATED','LBACSYS','OLAPDBA','OLAPSVR','OLAPSYS','OSE$HTTP$ADMIN','WKSYS','XDB','WMSYS','WK_TEST','WK_PROXY','SYSMAN','SI_INFORMTN_SCHEMA','SCOTT','MGMT_VIEW','MDDATA','EXFSYS','DMSYS','ANONYMOUS','BC4J','FLOWS_020000','FLOWS_FILES','OPS$ORACLE','OWBRT10GR1_REF','OWF_MGR','D4OSYS','CSMIG','PUBLIC','ADMINBO','ADMINBOXI','OWBRT_SYS','TSMSYS','AUDITBOXI') 
      and object_type='TYPE' and object_name not in (select object_name from dba_recyclebin)
group by owner,object_type order by 1;
clear breaks
clear computes
*/

/*
prompt
prompt Views by owner
select owner,object_type,count(*) cnt from dba_objects 
  where owner not in ('SYS','SYSTEM','OUTLN','DBSNMP','CTXSYS','DRSYS','MDSYS','ORDSYS','ORDPLUGINS','TRACESVR','AURORA$JIS$UTILITY$','AURORA$ORB$UNAUTHENTICATED','LBACSYS','OLAPDBA','OLAPSVR','OLAPSYS','OSE$HTTP$ADMIN','WKSYS','XDB','WMSYS','WK_TEST','WK_PROXY','SYSMAN','SI_INFORMTN_SCHEMA','SCOTT','MGMT_VIEW','MDDATA','EXFSYS','DMSYS','ANONYMOUS','BC4J','FLOWS_020000','FLOWS_FILES','OPS$ORACLE','OWBRT10GR1_REF','OWF_MGR','D4OSYS','CSMIG','PUBLIC','ADMINBO','ADMINBOXI','OWBRT_SYS','TSMSYS','AUDITBOXI') 
      and object_type='VIEW' and object_name not in (select object_name from dba_recyclebin)
group by owner,object_type order by 1;
clear breaks
clear computes
*/

/*
prompt
prompt Materialized Views by owner
select owner,object_type,count(*) cnt from dba_objects 
  where owner not in ('SYS','SYSTEM','OUTLN','DBSNMP','CTXSYS','DRSYS','MDSYS','ORDSYS','ORDPLUGINS','TRACESVR','AURORA$JIS$UTILITY$','AURORA$ORB$UNAUTHENTICATED','LBACSYS','OLAPDBA','OLAPSVR','OLAPSYS','OSE$HTTP$ADMIN','WKSYS','XDB','WMSYS','WK_TEST','WK_PROXY','SYSMAN','SI_INFORMTN_SCHEMA','SCOTT','MGMT_VIEW','MDDATA','EXFSYS','DMSYS','ANONYMOUS','BC4J','FLOWS_020000','FLOWS_FILES','OPS$ORACLE','OWBRT10GR1_REF','OWF_MGR','D4OSYS','CSMIG','PUBLIC','ADMINBO','ADMINBOXI','OWBRT_SYS','TSMSYS','AUDITBOXI') 
      and object_type='MATERIALIZED VIEW' and object_name not in (select object_name from dba_recyclebin)
group by owner,object_type order by 1;
clear breaks
clear computes
*/


/*
prompt
prompt Index by owner
select owner,object_type,count(*) cnt from dba_objects 
  where owner not in ('SYS','SYSTEM','OUTLN','DBSNMP','CTXSYS','DRSYS','MDSYS','ORDSYS','ORDPLUGINS','TRACESVR','AURORA$JIS$UTILITY$','AURORA$ORB$UNAUTHENTICATED','LBACSYS','OLAPDBA','OLAPSVR','OLAPSYS','OSE$HTTP$ADMIN','WKSYS','XDB','WMSYS','WK_TEST','WK_PROXY','SYSMAN','SI_INFORMTN_SCHEMA','SCOTT','MGMT_VIEW','MDDATA','EXFSYS','DMSYS','ANONYMOUS','BC4J','FLOWS_020000','FLOWS_FILES','OPS$ORACLE','OWBRT10GR1_REF','OWF_MGR','D4OSYS','CSMIG','PUBLIC','ADMINBO','ADMINBOXI','OWBRT_SYS','TSMSYS','AUDITBOXI') 
      and object_type='INDEX' and object_name not in (select object_name from dba_recyclebin)
group by owner,object_type order by 1;
clear breaks
clear computes
*/


/*
prompt
prompt Tables by owner
select owner,object_type,count(*) cnt from dba_objects 
  where owner not in ('SYS','SYSTEM','OUTLN','DBSNMP','CTXSYS','DRSYS','MDSYS','ORDSYS','ORDPLUGINS','TRACESVR','AURORA$JIS$UTILITY$','AURORA$ORB$UNAUTHENTICATED','LBACSYS','OLAPDBA','OLAPSVR','OLAPSYS','OSE$HTTP$ADMIN','WKSYS','XDB','WMSYS','WK_TEST','WK_PROXY','SYSMAN','SI_INFORMTN_SCHEMA','SCOTT','MGMT_VIEW','MDDATA','EXFSYS','DMSYS','ANONYMOUS','BC4J','FLOWS_020000','FLOWS_FILES','OPS$ORACLE','OWBRT10GR1_REF','OWF_MGR','D4OSYS','CSMIG','PUBLIC','ADMINBO','ADMINBOXI','OWBRT_SYS','TSMSYS','AUDITBOXI') 
      and object_type='TABLE' and object_name not in (select object_name from dba_recyclebin)
group by owner,object_type order by 1;
clear breaks
clear computes
*/


/*
prompt
prompt Segments by owner
break on owner skip 1
col mb for 99999.9999
select owner,segment_type,tablespace_name,count(*) cnt,sum(bytes)/1024/1024 Mb from dba_segments
  where owner not in ('SYS','SYSTEM','OUTLN','DBSNMP','CTXSYS','DRSYS','MDSYS','ORDSYS','ORDPLUGINS','TRACESVR','AURORA$JIS$UTILITY$','AURORA$ORB$UNAUTHENTICATED','LBACSYS','OLAPDBA','OLAPSVR','OLAPSYS','OSE$HTTP$ADMIN','WKSYS','XDB','WMSYS','WK_TEST','WK_PROXY','SYSMAN','SI_INFORMTN_SCHEMA','SCOTT','MGMT_VIEW','MDDATA','EXFSYS','DMSYS','ANONYMOUS','BC4J','FLOWS_020000','FLOWS_FILES','OPS$ORACLE','OWBRT10GR1_REF','OWF_MGR','D4OSYS','CSMIG','PUBLIC','ADMINBO','ADMINBOXI','OWBRT_SYS','TSMSYS','AUDITBOXI') 
group by owner,segment_type,tablespace_name order by 1;
clear breaks
clear computes
*/



/*
prompt
prompt Sequences by owner
select owner,object_type,count(*) cnt from dba_objects 
  where owner not in ('SYS','SYSTEM','OUTLN','DBSNMP','CTXSYS','DRSYS','MDSYS','ORDSYS','ORDPLUGINS','TRACESVR','AURORA$JIS$UTILITY$','AURORA$ORB$UNAUTHENTICATED','LBACSYS','OLAPDBA','OLAPSVR','OLAPSYS','OSE$HTTP$ADMIN','WKSYS','XDB','WMSYS','WK_TEST','WK_PROXY','SYSMAN','SI_INFORMTN_SCHEMA','SCOTT','MGMT_VIEW','MDDATA','EXFSYS','DMSYS','ANONYMOUS','BC4J','FLOWS_020000','FLOWS_FILES','OPS$ORACLE','OWBRT10GR1_REF','OWF_MGR','D4OSYS','CSMIG','PUBLIC','ADMINBO','ADMINBOXI','OWBRT_SYS','TSMSYS','AUDITBOXI') 
      and object_type='SEQUENCE' and object_name not in (select object_name from dba_recyclebin)
group by owner,object_type order by 1;
clear breaks
clear computes
*/

/*
prompt
prompt Synonym by owner
select owner,object_type,count(*) cnt from dba_objects 
  where owner not in ('SYS','SYSTEM','OUTLN','DBSNMP','CTXSYS','DRSYS','MDSYS','ORDSYS','ORDPLUGINS','TRACESVR','AURORA$JIS$UTILITY$','AURORA$ORB$UNAUTHENTICATED','LBACSYS','OLAPDBA','OLAPSVR','OLAPSYS','OSE$HTTP$ADMIN','WKSYS','XDB','WMSYS','WK_TEST','WK_PROXY','SYSMAN','SI_INFORMTN_SCHEMA','SCOTT','MGMT_VIEW','MDDATA','EXFSYS','DMSYS','ANONYMOUS','BC4J','FLOWS_020000','FLOWS_FILES','OPS$ORACLE','OWBRT10GR1_REF','OWF_MGR','D4OSYS','CSMIG','PUBLIC','ADMINBO','ADMINBOXI','OWBRT_SYS','TSMSYS','AUDITBOXI') 
      and object_type='SYNONYM' and object_name not in (select object_name from dba_recyclebin)
group by owner,object_type order by 1;
clear breaks
clear computes
*/



/*
prompt Roles et privileges pour les comptes XXX_X_OWN
col grantee for a15
col owner for a15
col table_name for a20
col grantor for a15
col privilege for a30

break on grantee skip 1 duplicates
--prompt dba_sys_privs
--SELECT 'grant '||privilege||' to '||grantee||decode(admin_option,'YES',' with admin option;',';') as "SYS privs" FROM dba_sys_privs WHERE grantee like '%OWN' or grantee='MSRS' order by grantee,privilege;


prompt dba_role_privs
SELECT 'grant '||rpad(GRANTED_ROLE,30,' ')||' to ' as gr,rpad(grantee,10,' ') as grantee,decode(admin_option,'YES',' with admin option;',';') as "ROLE privs" FROM dba_role_privs WHERE (grantee like '%OWN' or grantee like 'MSRS') 
and granted_role not in ('CONNECT','RESOURCE','DBA','SELECT_CATALOG_ROLE','EXECUTE_CATALOG_ROLE','DELETE_CATALOG_ROLE',
  'EXP_FULL_DATABASE','IMP_FULL_DATABASE','RECOVERY_CATALOG_OWNER','GATHER_SYSTEM_STATISTICS','LOGSTDBY_ADMINISTRATOR','AQ_ADMINISTRATOR_ROLE',
  'AQ_USER_ROLE','GLOBAL_AQ_USER_ROLE','SCHEDULER_ADMIN','HS_ADMIN_ROLE','OEM_ADVISOR','OEM_MONITOR','JAVAUSERPRIV','JAVAIDPRIV','JAVASYSPRIV',
  'JAVADEBUGPRIV','EJBCLIENT','JAVA_ADMIN','JAVA_DEPLOY','MGMT_USER','XDBADMIN','AUTHENTICATEDUSER','XDBWEBSERVICES','ORA_USER_CONNECT',
  'ORA_USER_RESOURCE','ORA_APPLI','OLAP_USER','WF_PLSQL_UI','WB_U_OWBRT10GR1_REF','OLAP_DBA','WB_D_OWBRT10GR1_REF','WB_R_OWBRT10GR1_REF',
  'WB_A_OWBRT10GR1_REF','D4OPUB','CTXAPP','WKUSER','WM_ADMIN_ROLE'
  )
order by grantee,granted_role;

--SELECT 'grant '||rpad(GRANTED_ROLE,30,' ')||' to ' as gr,rpad(grantee,10,' ') as grantee,decode(admin_option,'YES',' with admin option;',';') as "ROLE privs" FROM dba_role_privs WHERE (grantee like '%OWN' or grantee='MSRS') 
--and granted_role in ('CONNECT','RESOURCE','DBA','SELECT_CATALOG_ROLE','EXECUTE_CATALOG_ROLE','DELETE_CATALOG_ROLE',
--  'EXP_FULL_DATABASE','IMP_FULL_DATABASE','RECOVERY_CATALOG_OWNER','GATHER_SYSTEM_STATISTICS','LOGSTDBY_ADMINISTRATOR','AQ_ADMINISTRATOR_ROLE',
--  'AQ_USER_ROLE','GLOBAL_AQ_USER_ROLE','SCHEDULER_ADMIN','HS_ADMIN_ROLE','OEM_ADVISOR','OEM_MONITOR','JAVAUSERPRIV','JAVAIDPRIV','JAVASYSPRIV',
--  'JAVADEBUGPRIV','EJBCLIENT','JAVA_ADMIN','JAVA_DEPLOY','MGMT_USER','XDBADMIN','AUTHENTICATEDUSER','XDBWEBSERVICES','ORA_USER_CONNECT',
--  'ORA_USER_RESOURCE','ORA_APPLI','OLAP_USER','WF_PLSQL_UI','WB_U_OWBRT10GR1_REF','OLAP_DBA','WB_D_OWBRT10GR1_REF','WB_R_OWBRT10GR1_REF',
--  'WB_A_OWBRT10GR1_REF','D4OPUB','CTXAPP','WKUSER','WM_ADMIN_ROLE'
--  )
--order by grantee,granted_role;

clear columns
clear breaks
*/

---------------------------------------------     SYS    -----------------------------------------

/*
prompt System statistics (dbms_stats.gather_system_stats)
col sname for a20
col pname for a20
col pval1 for 9999999999.99
col pval2 for a20
select * from sys.aux_stats$ order by 1,2;
clear columns
*/




/*
prompt Database options installed from dba_registry
col comp_name for a40
select comp_name,status from dba_registry order by 1;
clear columns
*/



/*
prompt init.ora parameters
set lines 98 pages 200
column name format a33
column value format a64
select name,value from v$parameter where isdefault='FALSE' order by name;
set lines 132 pages 22
*/



/*
prompt database configuration
col filename for a80
col db_unique_name for a14
col force_logging for a13 head 'force logging'
col flashback_on for a12
select db_unique_name,log_mode,force_logging,flashback_on,supplemental_log_data_min,supplemental_log_data_pk,supplemental_log_data_ui,supplemental_log_data_fk,supplemental_log_data_all,status as bct_status,filename,bytes from v$database,v$block_change_tracking;
*/


/*
prompt database properties
clear columns
col property_name for a35
col property_value for a35
col description for a40
select * from database_properties where property_name in ('DEFAULT_PERMANENT_TABLESPACE','DEFAULT_TEMP_TABLESPACE','NLS_CHARACTERSET','DBTIMEZONE') order by 1;
clear columns
*/



/*
prompt Redo log configuration
col group#  format 999  heading 'Group'  
col member  format a45  heading 'Member' justify c 
col fsize   format 999  heading 'Size|(MB)'  
break on group# skip 1
select l.group#,member,(bytes/1024/1024) fsize from v$log l,v$logfile f where f.group# = l.group# order by 1;
clear columns
clear breaks
*/



/*
prompt controlfiles
col name for a80
select name from v$controlfile;
clear columns
*/


/*
prompt tablespaces
set lines 500 pages 200
col tablespace_name for a15 head 'TablespaceName'
col block_size for 9999 head 'Block'
col initial_extent format 999999999 head 'Ini'
col next_extent format 999999999 head 'Next'
col min_extents format 999999999 head 'Min_Ext'
col max_extents format 9999999999 head 'Max_Ext'
col pct_increase format 99 head '%Incr'
col MIN_EXTLEN for 99999999 head 'MinExtLen'
col status for a9 head 'Status'
col contents for a9 head 'Contents'
col logging for a9 head 'Logging'
col force_logging for a3 head 'Force'
col extent_management for a10 head 'ExtMgmt'
col allocation_type for a9 head 'AllocType'
col plugged_in for a3 head 'Plug'
col segment_space_management for a6 head 'SegmSpcMgmt'
col def_tab_compression for a8 head 'DefTabCompr'
col retention for a11 head 'Retention'
col bigfile for a3 head 'Big'
select tablespace_name,initial_extent,next_extent,max_extents,pct_increase,contents,logging,extent_management,allocation_type,segment_space_management,retention from dba_tablespaces;
clear columns
*/



/*
prompt jobs (old style)
column logpriv format a30 head "LogUser/PrivUser"
column job format 99999999 head "Job#"
column fail format a8 head "F/B/Sid"
col what for a80 head 'What'
select a.job,substr(a.what,instr(a.what,':='),80) as What,to_char(a.last_date,'dd/mm HH24:MI') as "Last",to_char(a.next_date,'dd/mm HH24:MI') as "Next",to_char(nvl(a.failures,0))||'/'||a.broken||'/'||to_char(nvl(b.sid,0)) as fail,a.log_user||'/'||a.priv_user as logpriv
from dba_jobs a,dba_jobs_running b where b.job(+)=a.job order by next_date desc;
clear columns
*/



/*
prompt jobs (Oracle 10g)
column logpriv format a21 head "Owner/ProgOwn"
column job_name format A25 head "JobName"
column fail format a15 head "F/Ena/Sid"
col what for a23 head 'What'
select a.job_name,substr(a.program_name,instr(a.program_name,':='),23) What,to_char(a.last_start_date,'dd/mm HH24:MI') "Last",to_char(a.next_run_date,'dd/mm HH24:MI') "Next"
,to_char(nvl(a.failure_count,0))||'/'||substr(a.enabled,1)||'/'||to_char(nvl(b.session_id,0)) as fail,substr(a.owner,1,10)||'/'||substr(a.program_owner,1,10) as logpriv
from dba_scheduler_jobs a,dba_scheduler_running_jobs b where b.owner(+)=a.owner and b.job_name(+)=a.job_name order by 1;
clear columns
*/



/*

prompt Roles et privileges pour le user CCT_ADM et le role CCT_R_ADM
set lines 200 pages 200 trimout on trimspool on
col grantee for a15
col owner for a15
col table_name for a20
col grantor for a15
col privilege for a30


prompt dba_sys_privs
SELECT 'grant '||privilege||' to cct_adm '||decode(admin_option,'YES','with admin option;',';') as "SYS privs to CCT_ADM" FROM dba_sys_privs WHERE grantee='CCT_ADM' order by privilege;


prompt dba_role_privs
SELECT 'grant '||GRANTED_ROLE||' to cct_adm '||decode(admin_option,'YES','with admin option;',';') as "ROLE privs to CCT_ADM" FROM dba_role_privs WHERE grantee='CCT_ADM' order by granted_role;


prompt dba_tab_privs
SELECT GRANTEE,OWNER,TABLE_NAME,GRANTOR,PRIVILEGE,GRANTABLE,HIERARCHY FROM dba_tab_privs WHERE grantee='CCT_ADM' order by 1,2,3,4,5;

prompt dba_ts_quotas
SELECT * FROM dba_ts_quotas WHERE username='CCT_ADM';

prompt dba_sys_privs
SELECT 'grant '||privilege||' to cct_adm '||decode(admin_option,'YES','with admin option;',';') as "SYS privs to CCT_R_ADM" FROM dba_sys_privs WHERE grantee='CCT_R_ADM' order by privilege;

prompt dba_role_privs
SELECT 'grant '||GRANTED_ROLE||' to cct_adm '||decode(admin_option,'YES','with admin option;',';') as "ROLE privs to CCT_R_ADM" FROM dba_role_privs WHERE grantee='CCT_R_ADM' order by granted_role;

prompt dba_tab_privs
SELECT GRANTEE,OWNER,TABLE_NAME,GRANTOR,PRIVILEGE,GRANTABLE,HIERARCHY FROM dba_tab_privs WHERE grantee='CCT_R_ADM' order by 1,2,3,4,5;
clear columns

*/
