/* olap_pga_performance.sql
This script determines how much PGA is in use, the size of the 
OLAP page pool, and the hit/miss ratio for OLAP pages for each user.
*/

col user format a12
col sid format 99999
col pga_used format a8
col pga_max format a8
col olap_pp format a8
col olap_ratio format a10

select vs.username, vs.sid, round(pga_used_mem/1024/1024,2)||' MB' pga_used, round(pga_max_mem/1024/1024,2)||' MB' pga_max, round(pool_size/1024/1024,2)||' MB' olap_pp, round(100*(pool_hits-pool_misses)/pool_hits,2) || '%' olap_ratio from v$process vp, v$session vs, v$aw_calc va where session_id=vs.sid and addr = paddr; 