--
--  Script    : initall.sql
--  Purpose   : Show all the v$parameter system parameters currently in efect
--  Tested on : 7.3,8,8i,9i,10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 163 pages 50
col num                 for 999 head 'Num' noprint
col name                for a43
col value               for a94
col type                for 999 head 'Typ' noprint
col isdefault           for a5  head 'Def?'
col isses_modifiable    for a8  head 'Sess?'
col issys_modifiable    for a9  head 'Sys?'
col ismodified          for a5  head 'Modif?'
col isadjusted          for a5  head 'Adju?'
ttitle left 'v$parameter'
spool /tmp/initall.lst
SELECT
    name
   ,value
   ,isdefault
   ,isses_modifiable
   ,issys_modifiable
FROM
    gv$parameter
WHERE
    inst_id=to_number(sys_context('USERENV','INSTANCE'))    
ORDER BY
    name
;
spool off

@rest_sqp_set

ed /tmp/initall.lst
