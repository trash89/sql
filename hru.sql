
@save_sqlplus_settings

prompt Buffer Hit Ratio for each connected user
select 
   substr(a.username,1,12) "User",
   a.sid "sid",
   b.consistent_gets "ConsGets",
   b.block_gets "BlockGets",
   b.physical_reads "PhysReads",
   100 * round((b.consistent_gets + b.block_gets - b.physical_reads) /(b.consistent_gets + b.block_gets),3) HitRatio
from v$session a, v$sess_io b
where a.sid = b.sid and  
      (b.consistent_gets + b.block_gets) > 0 and 
      a.username is not null
order by HitRatio asc;

@restore_sqlplus_settings

