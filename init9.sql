--
--  Script : init9.sql
--  Author : Marius RAICU
--  Purpose: Show the v$parameter2 system parameters currently in efect
--  For    : 9i
--
@save_sqlplus_settings
set lines 132 pages 200
column Name format a42
column Value format a64
col isses_modifiable for a5 head 'Sess?'
col issys_modifiable for a9 head 'Sys?'
select name,value,isses_modifiable,issys_modifiable from v$parameter2 where isdefault='FALSE' order by name;
set lines 132 pages 22
@restore_sqlplus_settings
