undef sch
accept sch char prompt 'Schema?:' default ''

@save_sqlplus_settings

SET lines 120 pages 100
set trimout on
set trimspool on
set define on
set autoprint off

col grantee for a15
col owner for a15
col table_name for a20
col grantor for a15
col privilege for a30

prompt dba_sys_privs
SELECT * FROM dba_sys_privs WHERE grantee=upper('&&sch');

prompt dba_role_privs
SELECT * FROM dba_role_privs WHERE grantee=upper('&&sch');

prompt dba_tab_privs
SELECT * FROM dba_tab_privs WHERE grantee=upper('&&sch');

prompt dba_ts_quotas
SELECT * FROM dba_ts_quotas WHERE username=upper('&&sch');

select lpad(' ', 2*level) || granted_role "User, his roles and privileges"
from
          (
            select null grantee, username granted_role
            from dba_users where username = upper('&&sch')
          union
            select grantee, granted_role
            from  dba_role_privs
          union
            select  grantee, privilege
            from dba_sys_privs
          )
start with grantee is null
connect by grantee = prior granted_role
/


@restore_sqlplus_settings
