REM FILE NAME:  cant_ext.sql
REM FUNCTION:   Report objects which cannot extend
REM TESTED ON:  7.3.3.5, 8.0.4.1
REM PLATFORM:   non-specific
REM REQUIRES:   sys.dba_segments, sys.dba_tables, sys.dba_clusters,
REM             sys.dba_indexes, sys.dba_rollback_segs, dba_free_space 
REM
REM  This is a part of the RevealNet Oracle Administration library. 
REM  Copyright (C) 1996-98 RevealNet, Inc. 
REM  All rights reserved. 
REM 
REM  For more information, call RevealNet at 1-800-REVEAL4 
REM  or check out our Web page: www.revealnet.com
REM 
REM*************** RevealNet Oracle Administration ***********************
REM
REM  Modifications (Date, Who, Description)
REM
set lines 132 pages 50
ttitle 'Objects Which Cannot Extend'
SELECT seg.owner,
       seg.segment_name,
       seg.segment_type,
       seg.tablespace_name,
       DECODE (
          seg.segment_type,
          'TABLE', t.next_extent,
          'CLUSTER', c.next_extent,
          'INDEX', i.next_extent,
          'ROLLBACK', r.next_extent
       )
  FROM sys.dba_segments seg,
       sys.dba_tables t,
       sys.dba_clusters c,
       sys.dba_indexes i,
       sys.dba_rollback_segs r
 WHERE  ( (   seg.segment_type = 'TABLE'
          AND seg.segment_name = t.table_name
          AND seg.owner = t.owner
          AND NOT EXISTS ( SELECT tablespace_name
                             FROM dba_free_space free
                            WHERE free.tablespace_name = t.tablespace_name
                              AND free.bytes >= t.next_extent))
       OR  (  seg.segment_type = 'CLUSTER'
          AND seg.segment_name = c.cluster_name
          AND seg.owner = c.owner
          AND NOT EXISTS ( SELECT tablespace_name
                             FROM dba_free_space free
                            WHERE free.tablespace_name = c.tablespace_name
                              AND free.bytes >= c.next_extent))
       OR  (  seg.segment_type = 'INDEX'
          AND seg.segment_name = i.index_name
          AND seg.owner = i.owner
          AND NOT EXISTS ( SELECT tablespace_name
                             FROM dba_free_space free
                            WHERE free.tablespace_name = i.tablespace_name
                              AND free.bytes >= i.next_extent))
       OR  (  seg.segment_type = 'ROLLBACK'
          AND seg.segment_name = r.segment_name
          AND seg.owner = r.owner
          AND NOT EXISTS ( SELECT tablespace_name
                             FROM dba_free_space free
                            WHERE free.tablespace_name = r.tablespace_name
                              AND free.bytes >= r.next_extent)))
    OR seg.extents = seg.max_extents
    OR seg.extents = ( SELECT value
                         FROM v$parameter
                        WHERE name = 'db_block_size')
/
set lines 80 pages 22
