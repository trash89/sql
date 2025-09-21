--
--  Script    : fra.sql
--  Purpose   : displays usage information about flashback recovery areas
--  Tested on : 10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 130 pages 50
set feed off 

-- reset the FRA
alter session set events 'immediate trace name kra_options level 1';
execute dbms_backup_restore.refreshagedfiles;

col name                for a70
col SPACE_LIMIT         for 999,999,999,999
col SPACE_USED          for 999,999,999,999
col SPACE_RECLAIMABLE   for 999,999,999,999 head 'Reclam'
col NUMBER_OF_FILES     for 99999 head 'Files'
ttitle left 'v$recovery_file_dest'
SELECT 
         name
        ,SPACE_LIMIT
        ,SPACE_USED
        ,SPACE_RECLAIMABLE
        ,NUMBER_OF_FILES
FROM 
    v$recovery_file_dest
;

col file_type                   for a25
col PERCENT_SPACE_USED          for 999,999.99 head '%SpaceUsed'
col PERCENT_SPACE_RECLAIMABLE   for 999,999.99 head '%SpaceReclam'
col NUMBER_OF_FILES             for 999999
ttitle left 'v$flash_recovery_area_usage'
SELECT * 
FROM 
    V$FLASH_RECOVERY_AREA_USAGE
;

rem for Oracle 10g,11g
rem SELECT * 
rem FROM 
rem     V$RECOVERY_AREA_USAGE
rem ;

@rest_sqp_set
