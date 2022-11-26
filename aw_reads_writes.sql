/* aw_reads_writes.sql
This script monitors the reads from temporary and permanent tablespaces,
the writes to cache, and the rows processed in attached analytic workspaces.
*/

set lines 110
col username format a15
col temp_reads format 999,999,999
col lob_reads format 999,999,999
col cache_wrs format 999,999,999
col rows_procd format 999,999,999

select username, sid, sum(temp_space_reads) temp_reads, sum(lob_reads) lob_reads, sum(cache_writes) cache_writes,sum(rows_processed) rows_processed from gv$aw_olap gvo, gv$session, gv$aw_calc gvc, gv$aw_longops gvl where sid=gvo.session_id and gvo.session_id=gvc.session_id group by username, sid;
