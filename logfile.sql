SET ECHO off 
ttitle - 
  left  'Redo Log Summary'  skip 2 
 
col group#  format 999      heading 'Group'  
col member  format a45  heading 'Member' justify c 
col status  format a10  heading 'Status' justify c   
col archived  format a10  heading 'Archived'   
col fsize   format 999  heading 'Size|(MB)'  
break on group# skip 1
select  l.group#, 
        member, 
        archived, 
        l.status, 
        (bytes/1024/1024) fsize 
from    v$log l, 
  v$logfile f 
where f.group# = l.group# 
order by 1 
/

clear columns
clear breaks
