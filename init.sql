--
--  Script : init.sql
--  Author : Marius RAICU
--  Purpose: Show the v$parameter system parameters currently in efect
--  Version: Oracle 7.3,8,8i,9i
--
@save_sqlplus_settings
set lines 150 pages 200
column name format a43
column value format a64
col isses_modifiable for a8 head 'Sess?'
col issys_modifiable for a9 head 'Sys?'
select name,value,isses_modifiable,issys_modifiable from v$parameter where isdefault='FALSE' order by name;
set lines 132 pages 22
@restore_sqlplus_settings
