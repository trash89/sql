--
--  Script    : lockint.sql
--  Purpose   : show internal locks FROM dba_lock_internal
--  Tested on : 8i+ 
--
@save_sqp_set

set lines 165 pages 50

col session_id      for 9999999 head 'Sid'
col lock_type       for a56
col mode_held       for a10
col mode_requested  for a10
col lock_id1        for a60 word_wrap
col lock_id2        for a16 word_wrap
ttitle left 'dba_lock_internal'
SELECT /*+ rule */
    *
FROM
    dba_lock_internal
;

@rest_sqp_set
