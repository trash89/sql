--
--  Script    : f.sql
--  Author    : Marius RAICU
--  Purpose   : show datafile informations
--  Tested on : Oracle 8i,9i,21c

set lines 160 pages 200 trimspool on trimout on feed off head on
clear computes

col FILE_NAME         format a70
col TABLESPACE_NAME   format a25
col MEG               format 999999.90 head 'Megs'
col increment_by      format 999999 head "Incr"
col file_id           format 99 head "Id"
col autoextensible    format a3 head 'Ext'
col INCLUDED_IN_DATABASE_BACKUP for a4 head 'Bck?'
col bigfile           for a8 head 'BigFile?'
col flashback_on      for a7 head 'FlBckOn'
break on report
compute sum of meg on report

select file_id,tablespace_name,bigfile,flashback_on,INCLUDED_IN_DATABASE_BACKUP,file_name,status,autoextensible,increment_by,bytes/1048576 meg
from dba_data_files,v$tablespace where dba_data_files.TABLESPACE_NAME = V$TABLESPACE.NAME order by tablespace_name;

clear computes
compute sum of meg on report

select file_id,tablespace_name,bigfile,flashback_on,INCLUDED_IN_DATABASE_BACKUP,file_name,status,autoextensible,increment_by,bytes/1048576 meg
from dba_temp_files,v$tablespace where dba_temp_files.TABLESPACE_NAME = V$TABLESPACE.NAME
order by tablespace_name;

clear columns
clear computes
set lines 150 pages 22 feed on

