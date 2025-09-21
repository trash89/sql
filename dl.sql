--
--  Script    : dl.sql
--  Purpose   : show DDL and DML locks
--  Tested on : 8i,9i,10g,11g,12c,19c,23c
--
@save_sqp_set

col owner            for a15 head 'User'
col session_id               head 'SID'
col mode_held        for a20 head 'Lock Mode|Held'
col mode_requested   for a20 head 'Lock Mode|Requested'
col type                     head 'Type|Object'
col name             for a30 head 'Object|Name'
set lines 140 pages 50
break on owner nodup on session_id nodup
ttitle left 'dba_DDL_locks'
SELECT
       nvl(owner,'SYS') owner,session_id,name,type,mode_held,mode_requested
FROM
       dba_ddl_locks
ORDER BY
       session_id
;

ttitle left 'dba_DML_locks'
SELECT
       nvl(owner,'SYS') owner,session_id,name,mode_held,mode_requested
FROM
       dba_dml_locks
ORDER BY
       session_id
;

@rest_sqp_set
