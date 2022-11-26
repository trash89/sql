-- shared_pool_hits.sql
-- This script calculates the shared pool hit ratio.

select trunc((1-(sum(getmisses)/sum(gets)))*100,3)||'%' "Shared Pool Hit Ratio" from v$rowcache;