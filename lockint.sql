
@save_sqlplus_settings

clear column
clear breaks
set lines 200 pages 60
spool locki.lst
col session_id 		for 9999999 head 'Sid'
col lock_type 		for a56
col mode_held 		for a10
col mode_requested 	for a10
col lock_id1 		for a60 word_wrap
col lock_id2 		for a10 word_wrap
select /*+ rule */ * from dba_lock_internal;
clear columns
set lines 150 pages 22
spool off

@restore_sqlplus_settings

