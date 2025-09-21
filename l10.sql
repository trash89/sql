--
--  Script    : l10.sql
--  Purpose   : show locked objects
--  Tested on : 8i+ 
--
@save_sqp_set

set lines 140 pages 50
break on sid skip 1 on oracle_username nodup on object_type nodup

col inst_id          for 9          head 'I'
col obj              for a60
col object_type      for a15
col oracle_username  for a25        head 'LockedBy'
col sid              for 9999999    head 'Sid'
col Type             for a10
ttitle left 'v$locked_object, dba_objects'
SELECT /*+ rule */
   b.session_id   as sid
  ,b.oracle_username  
  ,decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',
                      7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                      11, 'PACKAGE BODY', 12, 'TRIGGER',
                      13, 'TYPE', 14, 'TYPE BODY',
                      19, 'TABLE PARTITION', 20, 'INDEX PARTITION', 21, 'LOB',
                      22, 'LIBRARY', 23, 'DIRECTORY', 24, 'QUEUE',
                      28, 'JAVA SOURCE', 29, 'JAVA CLASS', 30, 'JAVA RESOURCE',
                      32, 'INDEXTYPE', 33, 'OPERATOR',
                      34, 'TABLE SUBPARTITION', 35, 'INDEX SUBPARTITION',
                      40, 'LOB PARTITION', 41, 'LOB SUBPARTITION',
                      42, CASE (SELECT BITAND(s.xpflags, 8388608 + 34359738368)
                                FROM sys.sum$ s
                                WHERE s.obj#=o.obj#)
                          WHEN 8388608 THEN 'REWRITE EQUIVALENCE'
                          WHEN 34359738368 THEN 'MATERIALIZED ZONEMAP'
                          ELSE 'MATERIALIZED VIEW'
                          END,
                      43, 'DIMENSION',
                      44, 'CONTEXT', 46, 'RULE SET', 47, 'RESOURCE PLAN',
                      48, 'CONSUMER GROUP',
                      51, 'SUBSCRIPTION', 52, 'LOCATION',
                      55, 'XML SCHEMA', 56, 'JAVA DATA',
                      57, 'EDITION', 59, 'RULE',
                      60, 'CAPTURE', 61, 'APPLY',
                      62, 'EVALUATION CONTEXT',
                      66, 'JOB', 67, 'PROGRAM', 68, 'JOB CLASS', 69, 'WINDOW',
                      72, 'SCHEDULER GROUP', 74, 'SCHEDULE', 79, 'CHAIN',
                      81, 'FILE GROUP', 82, 'MINING MODEL', 87, 'ASSEMBLY',
                      90, 'CREDENTIAL', 92, 'CUBE DIMENSION', 93, 'CUBE',
                      94, 'MEASURE FOLDER', 95, 'CUBE BUILD PROCESS',
                      100, 'FILE WATCHER', 101, 'DESTINATION',
                      111, 'CONTAINER',
                      114, 'SQL TRANSLATION PROFILE',
                      115, 'UNIFIED AUDIT POLICY',
                      144, 'MINING MODEL PARTITION',
                      148, 'LOCKDOWN PROFILE',
                      150, 'HIERARCHY',
                      151, 'ATTRIBUTE DIMENSION',
                      152, 'ANALYTIC VIEW',
                     'UNDEFINED') as object_type
  ,u.name||'.'||o.name as obj
  ,decode(b.locked_mode,1,'Null',2,'Row-S',3,'Row-X',4,'Share',5,'S/Row-X',6,'Exclu') "Type"
FROM
   sys.obj$    o
  ,sys.user$   u
  ,gv$locked_object b
WHERE
   b.object_id=o.obj#
   AND o.owner#=u.user#
   AND b.inst_id=to_number(sys_context('USERENV','INSTANCE'))   
ORDER BY 
   session_id
;

@rest_sqp_set
