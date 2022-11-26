--
--  Script    : t.sql
--  Author    : Marius RAICU
--  Purpose   : show tablespace informations
--  Tested on : Oracle 8i,9i

set feed off flush off verify off trimout on trimspool on
col tablespace_name   heading TablespaceName  format a30
col free_megs         heading 'Free MBytes' format 9999999.99
col perc_free         heading '% Free' format 999.99
col free_blocks       heading 'Free Blk'

col segment_type  heading SegType  format a10
col segment_name  heading SegType  format a30

set lines 120 pages 200
break on report
compute sum of freemb on report
compute sum of usedmb on report
compute sum of sizemb on report

col tablespace format a30
col SizeMB form 999g999g999

select 
  substr(tablespace_name,1,25) "Tablespace",
  round(sum(lalloc)/1024/1024,2) "SizeMB",
  round((sum(lalloc)/1024/1024)-(sum(lfree)/1024/1024),2) "UsedMB", 
  round(sum(lfree)/1024/1024,2) "FreeMB",
  round((sum(lalloc)-sum(lfree))/sum(lalloc)*100,2) "% Full",
  count(lfree)-1 "Frgt"
from
  (select tablespace_name,bytes lalloc,0 lfree from dba_data_files
  union all
  select tablespace_name,0 lalloc,bytes lfree from dba_free_space
  )
group by tablespace_name order by 4
;

set lines 500 pages 200

col tablespace_name for a30 head 'TablespaceName'
col block_size for 9999 head 'Block'
col initial_extent format 999999999 head 'Ini'
col next_extent format 999999999 head 'Next'
col min_extents format 999999999 head 'Min_Ext'
col max_extents format 9999999999 head 'Max_Ext'
col pct_increase format 99 head '%Incr'
col MIN_EXTLEN for 99999999 head 'MinExtLen'
col status for a9 head 'Status'
col contents for a9 head 'Contents'
col logging for a9 head 'Logging'
col force_logging for a3 head 'Force'
col extent_management for a10 head 'ExtMgmt'
col allocation_type for a9 head 'AllocType'
col plugged_in for a3 head 'Plug'
col segment_space_management for a6 head 'SegmSpcMgmt'
col def_tab_compression for a8 head 'DefTabCompr'
col retention for a11 head 'Retention'
col bigfile for a3 head 'Big'

select tablespace_name,to_char(round(initial_extent/1024))||'/'||to_char(round(next_extent/1024)) as ini_next,min_extents,max_extents,pct_increase,
       status,substr(contents,1,4) as contents,substr(logging,1,5) as logg,substr(extent_management,1,5) as Ext_Man,substr(allocation_type,1,4) as alloc 
from dba_tablespaces;

--select * from dba_tablespaces;

clear columns
set feed on flush on verify on pages 22 lines 150
clear columns
clear computes
clear breaks
