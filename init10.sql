--
--  Script    : init10.sql
--  Purpose   : Show the v$parameter system parameters currently in efect
--  Tested on : 9i,10g,11g
--
@save_sqp_set

set lines 153 pages 50
col Name                for a42
col Value               for a94
col isses_modifiable    for a5  head 'Sess?'
col issys_modifiable    for a9  head 'Sys?'
ttitle left 'v$parameter'
SELECT
    name
   ,value
   ,isses_modifiable
   ,issys_modifiable
FROM
    gv$parameter
WHERE
    isdefault='FALSE' or ismodified!='FALSE'
    AND inst_id=to_number(sys_context('USERENV','INSTANCE'))
ORDER BY
    name
;

@rest_sqp_set
