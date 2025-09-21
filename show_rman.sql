--
--  Script    : show_rman.sql
--  Purpose   : show rman backups
--  Tested on : 10g+
--
@save_sqp_set

set lines 82 pages 50

col STATUS          for a10
col start_timec     for a17 head 'START_TIME'
col end_timec       for a17 head 'END_TIME'
col hrs             for 999.99
ttitle left 'v$rman_backup_job_details'
SELECT 
     SESSION_KEY
    ,INPUT_TYPE
    ,STATUS
    ,to_char(START_TIME,'dd/mm/yyyy hh24:mi')   as start_timec
    ,to_char(END_TIME,'dd/mm/yyyy hh24:mi')     as end_timec
    ,elapsed_seconds/3600                       as hrs 
FROM 
    v$rman_backup_job_details
ORDER BY 
    session_key
;

@rest_sqp_set
