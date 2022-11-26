-- buffer_cache_hits.sql
-- This script calculates the buffer cache hit ratio.

select round(((1-(sum(decode(name, 'physical reads', value,0))/(sum(decode(name, 'db block gets', value,0))+ (sum(decode(name, 'consistent gets', value, 0))))))*100),2)|| '%' "Buffer Cache Hit Ratio" from v$sysstat;

