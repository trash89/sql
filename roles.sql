--
--  Script    : roles.sql
--  Purpose   : show roles FROM dba_roles
--  Tested on : 12c,19c,23c
--
@save_sqp_set

set lines 40 pages 50

col role                    for a30 head 'Role'
col oracle_maintained       for a7  head 'OraMnt'
ttitle left 'dba_roles'
SELECT
    role
   ,oracle_maintained
FROM
    dba_roles
ORDER BY
     oracle_maintained DESC
    ,role
;

@rest_sqp_set