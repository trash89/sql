--
--  Script    : users.sql
--  Purpose   : show the users in the database
--  Tested on : 12c,19c,23c
--
@save_sqp_set

set lines 180 pages 50
col username                for a30
col account_status          for a20
col default_tablespace      for a25 head 'Default TBS'
col temporary_tablespace    for a25 head 'Temp TBS'
col createdc                for a20 head 'Created'
col lastloginc              for a20 head 'LastLogin'
col password_versions       for a16 head 'PwdVers'
col oracle_maintained       for a7  head 'OraMnt'
col common                  for a4  head 'Comm'
ttitle left 'dba_users'
SELECT
    username
   ,account_status
   ,default_tablespace
   ,temporary_tablespace
   ,to_char(created,'dd/mm/yyyy hh24:mi:ss') as createdc
   ,to_char(last_login,'dd/mm/yyyy hh24:mi:ss') as lastloginc
   ,password_versions
   ,oracle_maintained
   ,common
FROM
    dba_users
ORDER BY
     oracle_maintained DESC
    ,username
;

@rest_sqp_set
