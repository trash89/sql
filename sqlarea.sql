--
--  Script    : sqlarea.sql
--  Purpose   : show queries and stats FROM v$sqlarea
--  Tested on : 8,8i,9i,10g,11g,12c,19c,23c
--
@save_sqp_set

set pages 50
col sql_id 	        for a13
col memory              noprint new_value m_memory
col sorts               noprint new_value m_sorts
col executions          noprint new_value m_executions
col first_load_time     noprint new_value m_first_load_time
col invalidations       noprint new_value m_invalidations
col parse_calls         noprint new_value m_parse_calls
col disk_reads          noprint new_value m_disk_reads
col buffer_gets         noprint new_value m_buffer_gets
col rows_processed      noprint new_value m_rows_processed
col row_ratio           noprint new_value m_row_ratio
col disk_ratio          noprint new_value m_disk_ratio
col buffer_ratio        noprint new_value m_buffer_ratio
break on row skip page
set heading off
ttitle-
"First load time: " m_first_load_time-
skip 1-
"Buffer gets:     " m_buffer_gets " ratio " m_buffer_ratio-
skip 1-
"Disk reads:      " m_disk_reads " ratio " m_disk_ratio-
skip 1-
"Rows delivered   " m_rows_processed " ratio " m_row_ratio-
skip 1-
"Executions       " m_executions-
skip 1-
"Parses           " m_parse_calls-
skip 1-
"Memory           " m_memory-
skip 1-
"Sorts            " m_sorts-
skip 1-
"Invalidations    " m_invalidations-
skip 2
spool /tmp/sqlarea.lst
set termout off
SELECT
        s.sql_id
       ,s.sharable_mem+s.persistent_mem+s.runtime_mem    memory
       ,s.sorts
       ,s.executions
       ,s.first_load_time
       ,s.invalidations
       ,s.parse_calls
       ,s.disk_reads
       ,s.buffer_gets
       ,s.rows_processed
       ,round(s.rows_processed/greatest(s.executions,1)) row_ratio
       ,round(s.disk_reads/greatest(s.executions,1))     disk_ratio
       ,round(s.buffer_gets/greatest(s.executions,1))    buffer_ratio
FROM
        gv$sqlarea s
WHERE
    (s.executions>100
     OR s.disk_reads>1000
     OR s.buffer_gets>1000
     OR s.rows_processed>1000
    )
    AND inst_id=to_number(sys_context('USERENV','INSTANCE'))
--    AND sys_context('USERENV','CON_ID')=s.con_id
ORDER BY
        s.executions*250+s.disk_reads*25+s.buffer_gets DESC
;
spool off

@rest_sqp_set

ed /tmp/sqlarea.lst
