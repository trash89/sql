--
--  Script    : resum.sql
--  Purpose   : show operations FROM dba_resumable
--  Tested on : 12c,19c,23c
--
@save_sqp_set

set lines 200 pages 50

col status          for a9
col START_TIME      for a17
col SUSPEND_TIME    for a17
col name            for a30
col ERROR_MSG       for a60
col SQL_TEXT        for a60
ttitle left 'dba_resumable'
SELECT 
     status
    ,start_time
    ,SUSPEND_TIME
    ,name
    ,ERROR_MSG
    ,SQL_TEXT 
FROM 
    dba_resumable
;

@rest_sqp_set
