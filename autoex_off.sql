
@save_sqlplus_settings

set lines 150 pages 0 head off trims on trim on
spool /tmp/autoex_off.sql
select 'alter database datafile '||chr(39)||file_name||chr(39)||' autoextend off;' from dba_data_files;
select 'alter database tempfile '||chr(39)||file_name||chr(39)||' autoextend off;' from dba_temp_files;
spool off
@/tmp/autoex_off
host rm -f /tmp/autoex_off.sql
@restore_sqlplus_settings

