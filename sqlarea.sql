set pagesize 999
set trimspool on
set feedback off
set verify off

clear columns
clear breaks

column  sql_text format a78 word_wrapped

column  memory          noprint new_value m_memory
column  sorts           noprint new_value m_sorts
column  executions      noprint new_value m_executions
column  first_load_time noprint new_value m_first_load_time
column  invalidations   noprint new_value m_invalidations
column  parse_calls     noprint new_value m_parse_calls
column  disk_reads      noprint new_value m_disk_reads
column  buffer_gets     noprint new_value m_buffer_gets
column  rows_processed  noprint new_value m_rows_processed

column  row_ratio       noprint new_value m_row_ratio
column  disk_ratio      noprint new_value m_disk_ratio
column  buffer_ratio    noprint new_value m_buffer_ratio

break on row skip page

set heading off
ttitle  -
        "First load time: " m_first_load_time -
        skip 1 -
        "Buffer gets:     " m_buffer_gets " ratio " m_buffer_ratio -
        skip 1 -
        "Disk reads:      " m_disk_reads  " ratio " m_disk_ratio -
        skip 1 -
        "Rows delivered   " m_rows_processed " ratio " m_row_ratio -
        skip 1 -
        "Executions       " m_executions -
        skip 1 -
        "Parses           " m_parse_calls -
        skip 1 -
        "Memory           " m_memory -
        skip 1 -
        "Sorts            " m_sorts -
        skip 1 -
        "Invalidations    " m_invalidations -
        skip 2

spool sqlarea.lst
set termout off

select 
        s.sql_text,
        s.sharable_mem + s.persistent_mem + s.runtime_mem memory,
        s.sorts,
        s.executions,
        s.first_load_time,
        s.invalidations,
        s.parse_calls,
        s.disk_reads,
        s.buffer_gets,
        s.rows_processed,
        round(s.rows_processed/greatest(s.executions,1))    row_ratio,
        round(s.disk_reads/greatest(s.executions,1))        disk_ratio,
        round(s.buffer_gets/greatest(s.executions,1))       buffer_ratio
from v$sqlarea s
--from sqlarea s
--,v$sqltext_with_newlines t
where(
        s.executions > 100
or      s.disk_reads > 1000
or      s.buffer_gets > 1000
or      s.rows_processed > 1000)
--and ( s.address=t.address and s.hash_value=t.hash_value)
order by
        s.executions * 250 + s.disk_reads * 25 + s.buffer_gets desc
;

spool off

ttitle off
clear breaks
set heading on termout on

