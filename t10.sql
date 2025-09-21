--
--  Script    : t10.sql
--  Purpose   : show tablespace informations
--  Tested on : 10g,11g,12c,19c
--
@save_sqp_set

set lines 126 pages 50
set feed off

col tablespace_name           for a30       head 'Tablespace'
col status                    for a9        head 'Status'
col contents                  for a21       head 'Contents'
col logging                   for a9        head 'Logging'
col force_logging             for a6        head 'ForceL'
col extent_management         for a10       head 'ExtMgmt'
col segment_space_management  for a7        head 'SegMgmt'
col allocation_type           for a9        head 'AllocType'
col retention                 for a11       head 'Retention'
col bigfile                   for a4        head 'BigF'
ttitle left 'dba_tablespaces'
SELECT
  tablespace_name
 ,status
 ,contents
 ,logging
 ,force_logging
 ,extent_management
 ,allocation_type
 ,segment_space_management
 ,retention
 ,bigfile
FROM
  dba_tablespaces
ORDER BY
  tablespace_name
;

ttitle off
col tablespace_name for a30         head 'Tablespace'
col SizeMB          for 999,999,999 head 'Size(MB)'
col UsedMB          for 999,999,999 head 'Used(MB)'
col FreeMB          for 999,999,999 head 'Free(MB)'
col pFull           for 999.99      head '%Full'
col Frgt            for 99,999
break on report
compute sum of freemb on report 
compute sum of usedmb on report 
compute sum of sizemb on report
SELECT
  tablespace_name
 ,round(sum(lalloc)/1024/1024,2)                          as SizeMB
 ,round((sum(lalloc)/1024/1024)-(sum(lfree)/1024/1024),2) as UsedMB
 ,round(sum(lfree)/1024/1024,2)                           as FreeMB
 ,round((sum(lalloc)-sum(lfree))/sum(lalloc)*100,2)       as pFull
 ,count(lfree)-1                                          as Frgt
FROM
  (
    SELECT tablespace_name,bytes lalloc,0 lfree
    FROM dba_data_files
    UNION ALL
    SELECT tablespace_name,0 lalloc,bytes lfree
    FROM dba_free_space
  )
GROUP BY
  tablespace_name
ORDER BY
  tablespace_name
;              

@rest_sqp_set
