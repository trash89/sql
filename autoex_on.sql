
@save_sqlplus_settings

set lines 150 pages 0 head off trims on trim on
spool /tmp/autoex_on.sql
select 'alter database datafile '||chr(39)||file_name||chr(39)||' autoextend on next 10M;' from dba_data_files;
select 'alter database tempfile '||chr(39)||file_name||chr(39)||' autoextend on next 10M;' from dba_temp_files;
spool off
@/tmp/autoex_on
host rm -f /tmp/autoex_on.sql

@restore_sqlplus_settings
