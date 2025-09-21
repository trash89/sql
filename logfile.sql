--
--  Script    : logfile.sql
--  Purpose   : show redo log and standby redo log info
--  Tested on : 10g,11g,12c,19c 
--
@save_sqp_set

set lines 200 pages 50
set feed off

ttitle left 'v$instance_recovery'
col target_mttr          for 9,999,999,999 head 'Target MTTR(s)'
col estimated_mttr       for 9,999,999,999 head 'Estimated MTTR(s)'
col optimal_logfile_size for 999,999,999   head 'Optimal Logfile(MB)'

SELECT 
         target_mttr
        ,estimated_mttr
        ,optimal_logfile_size
FROM 
        gV$INSTANCE_RECOVERY
WHERE 
        inst_id=to_number(sys_context('USERENV','INSTANCE'))
;

col dest_id             for 999 head 'Id'
col dest_name           for a45
col status              for a9
col binding             for a9
col schedule            for a8
col valid_now           for a16
col valid_type          for a15
col valid_role          for a12
col destination         for a74
ttitle left 'v$archive_dest'
SELECT 
         dest_id
        ,dest_name         
        ,status
        ,binding
        ,schedule
        ,valid_now
        ,valid_type
        ,valid_role 
        ,destination        
FROM 
        gv$archive_dest
WHERE 
        inst_id=to_number(sys_context('USERENV','INSTANCE'))
        AND status!='INACTIVE'
ORDER BY
        dest_id        
;

ttitle off
col db_unique_name      for a14
col target              for a7
col archiver            for a10
col net_timeout         for 9999999     head 'NetT(s)'
col log_sequence        for 99999999    head 'LogSeq'
col reopen_secs         for 999999      head 'Reop(s)'
col delay_mins          for 99999999    head 'Delay(min)'
col process             for a10
col register            for a3          head 'Reg'
col fail_datec          for a20         head 'Fail Date'
col fail_sequence       for 999999      head 'FailSeq'
col failure_count       for 9999        head 'Fail'
col transmit_mode       for a13
col affirm              for a3          head 'Aff'
col verify              for a3          head 'Vrf'
col compression         for a7          head 'Compres'
col error               for a48
SELECT 
         db_unique_name
        ,target
        ,archiver
        ,net_timeout
        ,log_sequence
        ,reopen_secs
        ,delay_mins
        ,process
        ,register
        ,to_date(fail_date,'dd/mm/yyyy hh24:mi:ss') as fail_datec
        ,fail_sequence
        ,failure_count
        ,transmit_mode
        ,affirm
        ,verify
--        ,compression
        ,error
FROM 
        gv$archive_dest 
WHERE 
        inst_id=to_number(sys_context('USERENV','INSTANCE')) 
        AND status!='INACTIVE' 
ORDER BY 
        dest_id
;

col group#      for 999         head 'Grp'
col thread#     for 999         head 'Thr'
col sequence#   for 999999      head 'Seq#'
col status      for a16         head 'Status'
col archived    for a10         head 'Archived'
col fsize       for 999,999     head 'Size(MB)'
col member      for a145        head 'Member'

break on group# skip 1
ttitle left 'Redo Log: v$log, v$logfile'
SELECT
        l.group#
       ,l.thread#
       ,l.sequence# 
       ,archived
       ,l.status
       ,(bytes/1024/1024) fsize
       ,member
FROM
        gv$log     l
       ,gv$logfile f
WHERE
        l.inst_id=f.inst_id
        AND l.inst_id=to_number(sys_context('USERENV','INSTANCE'))
        AND f.group#=l.group#
ORDER BY
        1
;

ttitle left 'Standby log: v$standby_log, v$logfile'
SELECT
        l.group#
       ,l.thread#
       ,l.sequence# 
       ,archived
       ,l.status
       ,(bytes/1024/1024) fsize
       ,member       
FROM
        gv$standby_log l
       ,gv$logfile     f
WHERE
        l.inst_id=f.inst_id
        AND l.inst_id=to_number(sys_context('USERENV','INSTANCE'))
        AND f.group#=l.group#
ORDER BY
        1
;

@rest_sqp_set
