column owner format a15
column name format a25
column table_name format a25
column updatable format a3 head "Upd"
select owner,name,table_name,updatable from dba_snapshots;
clear columns

