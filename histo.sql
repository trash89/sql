
@save_sqlplus_settings

undef own
undef tab
accept own char prompt 'Owner?: ' default '%'
accept tab char prompt 'Table?: ' default '%'
set lines 110 pages 80 trims on trim off feed on verify off
column owner format a15
column table_name format a25
column column_name format a35
break on owner skip 2 on table_name skip 1

select 
      owner,
      table_name,
      column_name, 
      count(*)
from 
      dba_histograms
where  
      owner not in ('SYS','SYSTEM','DBSNMP') and 
      upper(owner) like upper('%&&own%') and 
      upper(table_name) like upper('%&&tab%')
group by 
      owner,
      table_name,
      column_name;

clear columns
clear breaks
set verify on
undef own
undef tab

@restore_sqlplus_settings
