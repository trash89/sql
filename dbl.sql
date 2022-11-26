set lines 200
column owner format a15
column db_link format a25
column username format a15
column host format a80
select * from dba_db_links order by 1,2;
clear columns

