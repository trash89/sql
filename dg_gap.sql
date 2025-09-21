--
--  Script    : dg_gap.sql
--  Purpose   : Detecting Gaps for Standby database
--              To be run on mounted standby database
--  Tested on : 8i,9i,10g,11g
--
@save_sqp_set

set lines 200 pages 50
ttitle left 'received in v$archived_log, applied in v$log_history'
SELECT  high.thread#,"LowGap#","HighGap#"
FROM
  (
    SELECT thread#,min(sequence#)-1 "HighGap#"
    FROM
      (
        SELECT a.thread#,a.sequence#
        FROM
          (SELECT * FROM gv$archived_log WHERE inst_id=to_number(sys_context('USERENV','INSTANCE'))) a,
          (SELECT thread#,max(next_change#) gap1 FROM gv$log_history WHERE inst_id=to_number(sys_context('USERENV','INSTANCE')) GROUP BY thread# ) b
        WHERE
          a.thread#=b.thread#
          AND a.next_change#>gap1
      )
    GROUP BY thread#
  ) high
 ,(
    SELECT thread#,min(sequence#) "LowGap#"
    FROM
      (
        SELECT thread#,sequence#
        FROM gv$log_history,gv$datafile
        WHERE
          gv$log_history.inst_id=gv$datafile.inst_id
          AND gv$log_history.inst_id=to_number(sys_context('USERENV','INSTANCE'))
          AND checkpoint_change#<=next_change#
          AND checkpoint_change#>=first_change#
      )
    GROUP BY thread#
  ) low
WHERE
  low.thread#=high.thread#;

SELECT
  arch.thread#   "Thread"
 ,arch.sequence# "Last Sequence Received"
 ,appl.sequence# "Last Sequence Applied"
FROM
  (
    SELECT thread#,sequence#
    FROM gv$archived_log
    WHERE
      (thread#,first_time) IN (SELECT thread#,max(first_time) FROM gv$archived_log WHERE inst_id=to_number(sys_context('USERENV','INSTANCE')) GROUP BY thread#)
      AND inst_id=to_number(sys_context('USERENV','INSTANCE'))
  ) arch
 ,(
    SELECT thread#,sequence#
    FROM gv$log_history
    WHERE
      (thread#,first_time) IN (SELECT thread#,max(first_time) FROM gv$log_history WHERE inst_id=to_number(sys_context('USERENV','INSTANCE')) GROUP BY thread#)
      AND inst_id=to_number(sys_context('USERENV','INSTANCE'))
  ) appl
WHERE
  arch.thread#=appl.thread#
ORDER BY
  1
;

@rest_sqp_set
