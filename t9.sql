--
--  Script    : t9.sql
--  Author    : Marius RAICU
--  Purpose   : show tablespace informations
--  Tested on : Oracle 9i

set feed off flush off verify off
col tablespace_name 				heading TablespaceName  format a30
col free_megs						heading 'Free MBytes' format 9999999.99
col perc_free							heading '% Free' format 999.99
col free_blocks						heading 'Free Blk'
col tablespace_name				heading TablespaceName  format a30
col segment_type					heading SegType  format a10
col segment_name					heading SegType  format a30

set lines 80 pages 200
break on report
compute sum of free_bytes on report
col Alloc for 999g999g999
col Free for 999g999g999

select 
	substr(tablespace_name,1,25) "Tablespace",
	round(sum(lalloc)/1024/1024,2) "SizeMB",
	round(sum(lfree)/1024/1024,2) "FreeMB",
	round((sum(lalloc)-sum(lfree))/sum(lalloc)*100,2) "% Full",
	count(lfree)-1 "Frgt"
from
(select tablespace_name,bytes lalloc,0 lfree from dba_data_files
union all
select tablespace_name,0 lalloc,bytes lfree from dba_free_space
)
group by tablespace_name order by 4;

set lines 150 pages 200
col ini_ext 					for 9999999 head 'Ini_Ext|Ko'
col next_ext 				for 9999999 head 'Next_Ext|Ko'
col min_extents 		for 99999 head 'Min_Ext'
col pct_increase 		for 99 head '%Incr'
col segment_space_management for a9 head 'SegSpcMgmt'
select tablespace_name,
       initial_extent/1024 as ini_ext,
       next_extent/1024 as next_ext,
       min_extents,
       max_extents,
       pct_increase,
       status,
       substr(contents,1,4) as contents,
       substr(logging,1,5) as logg,
       substr(extent_management,1,5) as Ext_Man,
       substr(allocation_type,1,4) as alloc,
       segment_space_management 
from dba_tablespaces;
set feed on flush on verify on pages 22 lines 150
clear columns
clear computes
clear breaks
