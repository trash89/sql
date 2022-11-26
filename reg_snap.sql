accept site char prompt 'Site:'
set lines 150 pages 200
break on site skip 1
compute count of name on site
select owner,name,substr(snapshot_site,1,4) site,can_use_log,updatable,refresh_method,snapshot_id from dba_registered_snapshots
where substr(snapshot_site,1,4) like '%&&site%'
order by snapshot_site,owner,name;
clear breaks
clear computes

