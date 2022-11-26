--
--  Script : initall.sql
--  Author : Marius RAICU
--  Purpose: Show all the v$parameter system parameters currently in efect
--  Version: Oracle 7.3,8,8i,9i,10g,11g,12c
--
@save_sqlplus_settings
set lines 140 pages 200
col num for 999 head 'Num' noprint
col name format a43
col value format a64
col type for 999 head 'Typ' noprint
col isdefault for a5 head 'Def?'
col isses_modifiable for a8 head 'Sess?'
col issys_modifiable for a9 head 'Sys?'
col ismodified for a5 head 'Modif?'
col isadjusted for a5 head 'Adju?'
col description noprint
col update_comment noprint
spool /tmp/initall.lst
select name,value,isdefault,isses_modifiable,issys_modifiable from v$parameter  order by name;
spool off
set lines 132 pages 22
@restore_sqlplus_settings
ed /tmp/initall.lst

