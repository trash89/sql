--
--  Script    : meta.sql
--  Author    : Marius RAICU
--  Purpose   : Reverse-engineering for an application schema
--  Tested on : Oracle 10gr2 (10.2.0.1)
--              This script should be run from an account with SELECT ANY TABLE and SELECT_CATALOG_ROLE
-----------------------------------------------------------------------------------------

undef sch
accept sch char prompt 'Schema?:' default ''

undef pref
accept pref char prompt 'Prefix appl?:' default ''


set long 10000000
set lines 500 pagesize 0
set feedback off trimout on trimspool on autop off echo off verify off
col r for a500

execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'PRETTY',true);
execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SQLTERMINATOR',true);
execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'STORAGE',false,'TABLE');
execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'TABLESPACE',false,'TABLE');
execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'CONSTRAINTS',true,'TABLE');
execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'REF_CONSTRAINTS',false,'TABLE');
execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'CONSTRAINTS_AS_ALTER',true,'TABLE');
execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SIZE_BYTE_KEYWORD',true,'TABLE');
execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES',false,'TABLE');
execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES',false,'INDEX');
execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES',false,'CONSTRAINTS');
execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'INHERIT',true);

------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------            Users/Roles/Grants           -------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
spool \tmp\&&sch._cre_user_role.sql
prompt spool \tmp\&&sch._cre_user_role.log
select dbms_metadata.get_ddl('ROLE',role) as r 
from (
      select role from dba_roles 
      where 
        (role like '&pref.%' or role like 'UTL%') and 
        role not in ('CONNECT','RESOURCE','DBA','SELECT_CATALOG_ROLE','EXECUTE_CATALOG_ROLE','DELETE_CATALOG_ROLE','EXP_FULL_DATABASE',
        'IMP_FULL_DATABASE','RECOVERY_CATALOG_OWNER','GATHER_SYSTEM_STATISTICS','LOGSTDBY_ADMINISTRATOR','AQ_ADMINISTRATOR_ROLE',
        'AQ_USER_ROLE','GLOBAL_AQ_USER_ROLE','SCHEDULER_ADMIN','HS_ADMIN_ROLE','OEM_ADVISOR','OEM_MONITOR','JAVAUSERPRIV','JAVAIDPRIV',
        'JAVASYSPRIV','JAVADEBUGPRIV','EJBCLIENT','JAVA_ADMIN','JAVA_DEPLOY','MGMT_USER','XDBADMIN','AUTHENTICATEDUSER','XDBWEBSERVICES',
        'ORA_USER_CONNECT','ORA_USER_RESOURCE','ORA_APPLI','OLAP_USER','WF_PLSQL_UI','WB_U_OWBRT10GR1_REF','OLAP_DBA','WB_D_OWBRT10GR1_REF',
        'WB_R_OWBRT10GR1_REF','WB_A_OWBRT10GR1_REF','D4OPUB','CTXAPP','WKUSER','WM_ADMIN_ROLE'
        ) 
      order by 1
);

select dbms_metadata.get_granted_ddl('SYSTEM_GRANT',role) as r 
from ( 
      select distinct role from role_sys_privs 
      where 
        role in (
                select role from dba_roles 
                where 
                  (role like '&pref.%' or role like 'UTL%') and 
                  role not in ('CONNECT','RESOURCE','DBA','SELECT_CATALOG_ROLE','EXECUTE_CATALOG_ROLE','DELETE_CATALOG_ROLE','EXP_FULL_DATABASE',
                  'IMP_FULL_DATABASE','RECOVERY_CATALOG_OWNER','GATHER_SYSTEM_STATISTICS','LOGSTDBY_ADMINISTRATOR','AQ_ADMINISTRATOR_ROLE',
                  'AQ_USER_ROLE','GLOBAL_AQ_USER_ROLE','SCHEDULER_ADMIN','HS_ADMIN_ROLE','OEM_ADVISOR','OEM_MONITOR','JAVAUSERPRIV','JAVAIDPRIV',
                  'JAVASYSPRIV','JAVADEBUGPRIV','EJBCLIENT','JAVA_ADMIN','JAVA_DEPLOY','MGMT_USER','XDBADMIN','AUTHENTICATEDUSER','XDBWEBSERVICES',
                  'ORA_USER_CONNECT','ORA_USER_RESOURCE','ORA_APPLI','OLAP_USER','WF_PLSQL_UI','WB_U_OWBRT10GR1_REF','OLAP_DBA','WB_D_OWBRT10GR1_REF',
                  'WB_R_OWBRT10GR1_REF','WB_A_OWBRT10GR1_REF','D4OPUB','CTXAPP','WKUSER','WM_ADMIN_ROLE'
                  )
              ) 
      order by 1
);

select dbms_metadata.get_granted_ddl('ROLE_GRANT',role) as r 
from (
      select distinct role from role_role_privs 
      where 
        role in (
                select role from dba_roles 
                where 
                  (role like '&pref.%' or role like 'UTL%') and 
                  role not in ('CONNECT','RESOURCE','DBA','SELECT_CATALOG_ROLE','EXECUTE_CATALOG_ROLE','DELETE_CATALOG_ROLE','EXP_FULL_DATABASE',
                  'IMP_FULL_DATABASE','RECOVERY_CATALOG_OWNER','GATHER_SYSTEM_STATISTICS','LOGSTDBY_ADMINISTRATOR','AQ_ADMINISTRATOR_ROLE',
                  'AQ_USER_ROLE','GLOBAL_AQ_USER_ROLE','SCHEDULER_ADMIN','HS_ADMIN_ROLE','OEM_ADVISOR','OEM_MONITOR','JAVAUSERPRIV','JAVAIDPRIV',
                  'JAVASYSPRIV','JAVADEBUGPRIV','EJBCLIENT','JAVA_ADMIN','JAVA_DEPLOY','MGMT_USER','XDBADMIN','AUTHENTICATEDUSER','XDBWEBSERVICES',
                  'ORA_USER_CONNECT','ORA_USER_RESOURCE','ORA_APPLI','OLAP_USER','WF_PLSQL_UI','WB_U_OWBRT10GR1_REF','OLAP_DBA','WB_D_OWBRT10GR1_REF',
                  'WB_R_OWBRT10GR1_REF','WB_A_OWBRT10GR1_REF','D4OPUB','CTXAPP','WKUSER','WM_ADMIN_ROLE'
                  ) 
              ) 
      order by 1
);

select dbms_metadata.get_granted_ddl('OBJECT_GRANT',role) as r 
from (
  select distinct role from role_tab_privs 
  where 
    role in (
            select role from dba_roles 
            where 
              (role like '&pref.%' or role like 'UTL%') and 
              role not in ('CONNECT','RESOURCE','DBA','SELECT_CATALOG_ROLE','EXECUTE_CATALOG_ROLE','DELETE_CATALOG_ROLE','EXP_FULL_DATABASE',
              'IMP_FULL_DATABASE','RECOVERY_CATALOG_OWNER','GATHER_SYSTEM_STATISTICS','LOGSTDBY_ADMINISTRATOR','AQ_ADMINISTRATOR_ROLE',
              'AQ_USER_ROLE','GLOBAL_AQ_USER_ROLE','SCHEDULER_ADMIN','HS_ADMIN_ROLE','OEM_ADVISOR','OEM_MONITOR','JAVAUSERPRIV','JAVAIDPRIV',
              'JAVASYSPRIV','JAVADEBUGPRIV','EJBCLIENT','JAVA_ADMIN','JAVA_DEPLOY','MGMT_USER','XDBADMIN','AUTHENTICATEDUSER','XDBWEBSERVICES',
              'ORA_USER_CONNECT','ORA_USER_RESOURCE','ORA_APPLI','OLAP_USER','WF_PLSQL_UI','WB_U_OWBRT10GR1_REF','OLAP_DBA','WB_D_OWBRT10GR1_REF',
              'WB_R_OWBRT10GR1_REF','WB_A_OWBRT10GR1_REF','D4OPUB','CTXAPP','WKUSER','WM_ADMIN_ROLE'
              ) 
          ) 
  order by 1
);

select dbms_metadata.get_ddl('USER','&sch') as r 
from (
      select 1 from dba_users where username='&sch'
);

select dbms_metadata.get_granted_ddl('ROLE_GRANT','&sch') as r 
from (
      select distinct 1 from dba_users D,dba_role_privs s 
      where 
        d.username=s.grantee and 
        d.username='&sch'
    );

select dbms_metadata.get_granted_ddl('TABLESPACE_QUOTA','&sch') as r 
from (
      select distinct 1 from dba_users D,dba_role_privs s,dba_ts_quotas q 
      where 
        d.username=s.grantee and 
        d.username=q.username and 
        d.username='&sch'
);

select dbms_metadata.get_granted_ddl('DEFAULT_ROLE','&sch') as r 
from (
    select distinct 1 from dba_users D,dba_role_privs s 
    where 
      d.username=s.grantee and 
      d.username='&sch' and 
      s.default_role='YES'
);

select dbms_metadata.get_granted_ddl('SYSTEM_GRANT','&sch') as r 
from (
    select distinct 1 from dba_users D,dba_sys_privs s 
    where 
      d.username=s.grantee and 
      d.username='&sch'
);

select dbms_metadata.get_granted_ddl('OBJECT_GRANT','&sch') as r 
from (
  select distinct 1 from dba_users D, dba_tab_privs s 
  where 
    d.username=s.grantee and 
    d.username='&sch'
);
prompt spool off
spool off




------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------            Database Links               -------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
spool \tmp\&&sch._cre_db_link.sql
prompt spool \tmp\&&sch._cre_db_link.log
select dbms_metadata.get_ddl('DB_LINK',object_name,'&sch') as r from (
  select object_name from dba_objects      
  where 
    owner='&sch' and 
    object_type='DATABASE LINK' and 
    object_name not in (select object_name from dba_recyclebin where owner='&sch')
  order by 1
);
prompt spool off
spool off



------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------            Tables                       -------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
spool \tmp\&&sch._cre_tab.sql
prompt spool \tmp\&&sch._cre_tab.log
select dbms_metadata.get_ddl('TABLE',object_name,'&sch') as r from (
  select object_name from dba_objects      
  where 
    owner='&sch' and 
    object_type='TABLE' and 
    object_name not in (select object_name from dba_recyclebin where owner='&sch') and 
    object_name not in (select mview_name from dba_mviews where owner='&sch')
  order by 1
);
prompt spool off
spool off



------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------            Functions                    -------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
spool \tmp\&&sch._cre_func.sql
prompt spool \tmp\&&sch._cre_func.log
select dbms_metadata.get_ddl('FUNCTION',object_name,'&sch') as r from (
  select object_name from dba_objects      
  where 
    owner='&sch' and 
    object_type='FUNCTION' and 
    object_name not in (select object_name from dba_recyclebin where owner='&sch')
  order by 1
);
prompt spool off
spool off


------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------            Procedures                   -------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
spool \tmp\&&sch._cre_proc.sql
prompt spool \tmp\&&sch._cre_proc.log
select dbms_metadata.get_ddl('PROCEDURE',object_name,'&sch') as r from (
  select object_name from dba_objects      
  where 
    owner='&sch' and 
    object_type='PROCEDURE' and 
    object_name not in (select object_name from dba_recyclebin where owner='&sch')
  order by 1
);
prompt spool off
spool off



------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------            Indexes                      -------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
spool \tmp\&&sch._cre_ind.sql
prompt spool \tmp\&&sch._cre_ind.log
select dbms_metadata.get_ddl('INDEX',object_name,'&sch') as r from (
  select object_name from dba_objects      
  where 
    owner='&sch' and 
    object_type='INDEX' and 
    object_name not in (select object_name from dba_recyclebin where owner='&sch')
  order by 1
);
prompt spool off
spool off



------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------            Types                        -------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
spool \tmp\&&sch._cre_type.sql
prompt spool \tmp\&&sch._cre_type.log
select dbms_metadata.get_ddl('TYPE',object_name,'&sch') as r from (
  select object_name from dba_objects      
  where 
    owner='&sch' and 
    object_type='TYPE' and 
    object_name not in (select object_name from dba_recyclebin where owner='&sch')
  order by 1
);
prompt spool off
spool off



------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------            Packages                     -------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
spool \tmp\&&sch._cre_pack.sql
prompt spool \tmp\&&sch._cre_pack.log
select dbms_metadata.get_ddl('PACKAGE',object_name,'&sch') as r from (
  select object_name from dba_objects      
  where 
    owner='&sch' and 
    object_type='PACKAGE' and 
    object_name not in (select object_name from dba_recyclebin where owner='&sch')
  order by 1
);
prompt spool off
spool off




------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------            Sequences                    -------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
spool \tmp\&&sch._cre_seq.sql
prompt spool \tmp\&&sch._cre_seq.log
select dbms_metadata.get_ddl('SEQUENCE',object_name,'&sch') as r from (
  select object_name from dba_objects      
  where 
    owner='&sch' and 
    object_type='SEQUENCE' and 
    object_name not in (select object_name from dba_recyclebin where owner='&sch')
  order by 1
);
prompt spool off
spool off




------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------            Views                        -------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
spool \tmp\&&sch._cre_view.sql
prompt spool \tmp\&&sch._cre_view.log
select dbms_metadata.get_ddl('VIEW',object_name,'&sch') as r from (
  select object_name from dba_objects      
  where 
    owner='&sch' and 
    object_type='VIEW' and 
    object_name not in (select object_name from dba_recyclebin where owner='&sch')
  order by 1
);
prompt spool off
spool off




------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------            Synonyms                     -------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
spool \tmp\&&sch._cre_syn.sql
prompt spool \tmp\&&sch._cre_syn.log
select dbms_metadata.get_ddl('SYNONYM',object_name,'&sch') as r from (
  select object_name from dba_objects      
  where 
    owner='&sch' and 
    object_type='SYNONYM' and 
    object_name not in (select object_name from dba_recyclebin where owner='&sch')
  order by 1
);
prompt spool off
spool off




------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------            Directories                  -------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
spool \tmp\&&sch._cre_dir.sql
prompt spool \tmp\&&sch._cre_dir.log
select dbms_metadata.get_ddl('DIRECTORY',directory_name) as r from (
  select directory_name from dba_directories 
  where directory_name in (select table_name from dba_tab_privs where grantee='&sch') 
  order by 1
);

select dbms_metadata.get_granted_ddl('OBJECT_GRANT','&sch') as r 
from (
      select distinct 1 from dba_users D, dba_tab_privs s,dba_directories dir 
      where 
        dir.directory_name in (select table_name from dba_tab_privs where grantee='&sch') and 
        d.username=s.grantee and 
        d.username='&sch'
    );
prompt spool off
spool off



------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------            Materialized Views           -------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
spool \tmp\&&sch._cre_mv.sql
prompt spool \tmp\&&sch._cre_mv.log
select dbms_metadata.get_ddl('MATERIALIZED_VIEW',object_name,'&sch') as r from (
  select object_name from dba_objects      
  where 
    owner='&sch' and 
    object_type='MATERIALIZED VIEW' and 
    object_name not in (select object_name from dba_recyclebin where owner='&sch')
  order by 1
);

select dbms_metadata.get_dependent_ddl('MATERIALIZED_VIEW_LOG',master,'&sch') as r from (
  select distinct master from dba_mview_logs
  where 
    log_owner='&sch'
  order by 1
);
prompt spool off
spool off




------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------            VPD/RLS                      -------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
spool \tmp\&&sch._cre_vpd.sql
prompt spool \tmp\&&sch._cre_vpd.log
select dbms_metadata.get_ddl('CONTEXT',namespace) as r from (
  select distinct namespace from dba_context
  where schema='&sch'
  order by 1
);

select dbms_metadata.get_dependent_ddl('RLS_GROUP',object_name,'&sch') as r 
from (
      select distinct object_name from dba_policy_groups 
      where 
        object_owner='&sch' 
      order by 1
    );

select dbms_metadata.get_dependent_ddl('RLS_POLICY',object_name,'&sch') as r 
from (
      select distinct object_name from dba_policies     
      where 
        object_owner='&sch' 
      order by 1
    );
prompt spool off
spool off



------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------            Foreign Keys                 -------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
spool \tmp\&&sch._cre_fk.sql
prompt spool \tmp\&&sch._cre_fk.log
select dbms_metadata.get_ddl('REF_CONSTRAINT',constraint_name,'&sch') as r from (
  select constraint_name from dba_constraints  
  where 
    owner='&sch' and 
    constraint_type='R'
  order by 1
);
prompt spool off
spool off




------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------            Triggers                     -------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
spool \tmp\&&sch._cre_trig.sql
prompt spool \tmp\&&sch._cre_trig.log
select dbms_metadata.get_ddl('TRIGGER',object_name,'&sch') as r from (
  select object_name from dba_objects      
  where 
    owner='&sch' and 
    object_type='TRIGGER' and 
    object_name not in (select object_name from dba_recyclebin where owner='&sch')
  order by 1
);
prompt spool off
spool off



------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------            Grants                     -------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
spool \tmp\&&sch._cre_grant.sql
prompt spool \tmp\&&sch._cre_grant.log
select dbms_metadata.get_dependent_ddl('OBJECT_GRANT',table_name,'&sch') as r 
from (
      select 
        distinct t.table_name 
      from 
        dba_objects o,dba_tab_privs t 
      where 
        o.owner='&sch' and 
        o.object_type in ('PROCEDURE','FUNCTION','VIEW','TABLE','MATERIALIZED VIEW','TYPE','SEQUENCE','PACKAGE') and 
        not exists (select  r.object_name from dba_recyclebin r where r.owner='&sch' and r.object_name=o.object_name) and 
        o.owner=t.owner and 
        o.object_name=t.table_name
      order by 1
      );
prompt spool off
spool off





------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------            Generating Install Script    -------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
spool \tmp\install_&&sch..sql
prompt
prompt prompt Installation du schema &&sch
prompt
prompt prompt (Remplacez les valeurs 'pwd' et 'db' avec les password et le nom de la base cible
prompt
prompt
prompt connect cct_adm/pwd@db
prompt
prompt @@&&sch._cre_user_role.sql
prompt
prompt @@&&sch._cre_dir.sql
prompt
prompt disconnect
prompt
prompt
prompt connect &sch/pwd@db
prompt
prompt
prompt @@&&sch._cre_db_link.sql
prompt
prompt @@&&sch._cre_tab.sql
prompt
prompt @@&&sch._cre_func.sql
prompt
prompt @@&&sch._cre_proc.sql
prompt
prompt @@&&sch._cre_type.sql
prompt
prompt @@&&sch._cre_pack.sql
prompt
prompt @@&&sch._cre_seq.sql
prompt
prompt @@&&sch._cre_view.sql
prompt
prompt @@&&sch._cre_syn.sql
prompt
prompt @@&&sch._cre_dir.sql
prompt
prompt @@&&sch._cre_mv.sql
prompt
prompt @@&&sch._cre_ind.sql
prompt
prompt @@&&sch._cre_vpd.sql
prompt
prompt @@&&sch._cre_fk.sql
prompt
prompt @@&&sch._cre_trig.sql
prompt
prompt @@&&sch._cre_grant.sql
prompt
prompt
prompt disconnect
prompt
spool off

clear columns
execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'DEFAULT');
undef sch
undef pref

