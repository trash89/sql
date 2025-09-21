--
--  Script    : ratio.sql
--  Purpose   : calculate diverse ratio
--  Tested on : 8i+ 
--
@save_sqp_set

set termout off lines 141 pages 50

col count           for 99,999,999,999
col value           for 99,999,999,999
col MisRat          for 99.9999
col ImmedMissRat    for 99.9999
col time_waited     for 99,999,999,999,999,999
variable dbbg number;
variable cg number;
variable pr number;
variable rlsr number;
variable re number;
BEGIN
      -- Buffer Cache Hit Ratio: Target BCHR>95
     SELECT value INTO :dbbg FROM gv$sysstat WHERE name='db block gets' AND inst_id=to_number(sys_context('USERENV','INSTANCE'))  ;
     SELECT value INTO :cg   FROM gv$sysstat WHERE name='consistent gets' AND inst_id=to_number(sys_context('USERENV','INSTANCE'))  ;
     SELECT value INTO :pr   FROM gv$sysstat WHERE name='physical reads' AND inst_id=to_number(sys_context('USERENV','INSTANCE'))  ;
      -- Log Buffer Hit Ratio : Target 1/5000
     SELECT value INTO :rlsr FROM gv$sysstat WHERE name='redo log space requests' AND inst_id=to_number(sys_context('USERENV','INSTANCE'))  ;
     SELECT value INTO :re   FROM gv$sysstat WHERE name='redo entries' AND inst_id=to_number(sys_context('USERENV','INSTANCE'))  ;
END;
/
set termout on

set head off feed off
SELECT 
     'BufHitRatio(>95%) = '||to_char((1-(:pr/(:dbbg+ :cg)))*100,'999.99') valoare  
FROM 
     dual
;

SELECT 
     'LibCache HitRatio = '||to_char((1-(sum(reloads)/sum(pins)))*100,'999.99')    
FROM 
     gv$librarycache
WHERE
     inst_id=to_number(sys_context('USERENV','INSTANCE'))  
;

SELECT 
     'DataDict Miss%    = '||to_char((sum(getmisses)/sum(gets)),'999.99')          
FROM 
     gv$rowcache
WHERE
     inst_id=to_number(sys_context('USERENV','INSTANCE'))  
;

set head on

col name                 for a50     head 'Name'
col gets                 for 999,999,999,999
col misses               for 999,999,999,999
col immediate_gets       for 999,999,999,999
col immediate_misses     for 999,999,999,999
col MisRat          for a10     head 'MisRat'
col ImmMissRat      for a10     head 'ImmMissRat'
ttitle left 'v$latch - Latch Contention Cache Buffers and Library Cache'
SELECT
     name
    ,gets
    ,misses
    ,immediate_gets
    ,immediate_misses
    ,to_char(misses/decode(gets,0,1,gets)*100,'999.99')                               AS MisRat
    ,to_char(immediate_misses/decode(immediate_gets,0,1,immediate_gets)*100,'999.99') as ImmMissRat
FROM
     gv$latch
WHERE
     inst_id=to_number(sys_context('USERENV','INSTANCE'))  
     AND (misses>0 OR immediate_misses>0)
     AND (name LIKE 'cache bu%' OR name LIKE 'library cach%')
;

ttitle left 'v$segment_statistics - buffer busy waits'
col tablespace_name for a25
col obj for a60
col statistic_name for a30
SELECT 
      tablespace_name,owner||'.'||object_name obj
     ,value
FROM 
     gv$segment_statistics
WHERE 
     statistic_name='buffer busy waits' 
     AND value>10
     AND inst_id=to_number(sys_context('USERENV','INSTANCE'))  
ORDER BY 
     value
;

--The cache buffer LRU chain latch is needed when it’s time to scan the LRU chain for dirty blocks, and is also used when Oracle needs a free block in the SGA.
--The cache buffer chains latch is acquired when a process needs to search the buffer cache
--If the ratio of misses to gets is high (misses/gets*100) is > 10, then you need to determine why you are having a cache buffer chain latching issue and do something about it.

col name                    for a7
col free_buffer_wait        for 99,999,999          head "FreeBW"
col write_complete_wait     for 99,999,999          head "WriteCW"
col buffer_busy_wait        for 9,999,999,999,999   head "BufBusyW"
col db_block_gets           for 9,999,999,999,999   head "DbBgets"
col consistent_gets         for 9,999,999,999,999   head "ConsistGets"
col physical_reads          for 9,999,999,999,999   head "PhysReads"
col ratio                   for 999.99              head "Ratio"
ttitle left 'v$buffer_pool_statistics'
SELECT
    name
   ,free_buffer_wait
   ,write_complete_wait
   ,buffer_busy_wait
   ,db_block_gets
   ,consistent_gets
   ,physical_reads
   ,1-(physical_reads/(db_block_gets+consistent_gets))as ratio
FROM
    gv$buffer_pool_statistics
WHERE
     inst_id=to_number(sys_context('USERENV','INSTANCE'))      
;

@rest_sqp_set
