--
--  Script : show_dbfiles10.sql
--  Purpose: Show all dest parameters,datafiles,tempfiles,redo log files
--  Version: 10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 144 pages 50 

col name        for a43
col value       for a100
ttitle left 'parameters'
SELECT * FROM (
SELECT 
     name
    ,value 
FROM 
    gv$parameter2
WHERE name in (
     'control_files'
    ,'audit_file_dest'
    ,'background_dump_dest'
    ,'core_dump_dest'
    ,'user_dump_dest'
    ,'diagnostic_dest'    
    ,'db_create_file_dest'
    ,'db_recovery_file_dest'
    ,'diagnostic_dest'
    ,'dg_broker_config_file1'
    ,'dg_broker_config_file2'
    ,'spfile'
    ,'log_archive_duplex_dest'
    ,'remote_recovery_file_dest'
    ,'standby_archive_dest'
    )
    AND value IS NOT NULL
    AND inst_id=to_number(sys_context('USERENV','INSTANCE'))
union all
SELECT 
     name
    ,value 
FROM 
    gv$parameter2
WHERE 
    name like 'log_archive_dest%'
    AND name like 'db_create_online_log_dest%'    
    AND name not like 'log_archive_dest_state%'
    AND value IS NOT NULL
    AND inst_id=to_number(sys_context('USERENV','INSTANCE'))
union all
SELECT 'data file' as name,file_name as value  FROM dba_data_files
union all
SELECT 'temp file' as name,file_name as value  FROM dba_temp_files
union all
SELECT 'redo log file' as name, member as value FROM gv$logfile WHERE inst_id=to_number(sys_context('USERENV','INSTANCE'))
union all
SELECT 'block change tracking' as name,filename as value FROM v$block_change_tracking
union all
SELECT 'flashback database logfile' as name,f.name as value FROM gv$flashback_database_logfile f WHERE f.inst_id=to_number(sys_context('USERENV','INSTANCE'))
union all
SELECT DISTINCT 'tde folder' as name,wrl_parameter as value  FROM gv$encryption_wallet WHERE wrl_parameter IS NOT NULL AND inst_id=to_number(sys_context('USERENV','INSTANCE'))
)
ORDER BY 
     2
    ,1
;

col folder      for a100 head 'Database folders'
ttitle left 'synthese'
SELECT DISTINCT folder FROM (
    SELECT name,case when instr(value,'.',-1)>0 then substr(value,1,instr(value,'/',-1)-1) else value end as folder
    FROM gv$parameter2
    WHERE name in (
     'control_files'
    ,'audit_file_dest'
    ,'background_dump_dest'
    ,'core_dump_dest'
    ,'user_dump_dest'
    ,'diagnostic_dest'    
    ,'db_create_file_dest'
    ,'db_recovery_file_dest'
    ,'diagnostic_dest'
    ,'dg_broker_config_file1'
    ,'dg_broker_config_file2'
    ,'spfile'
    ,'log_archive_duplex_dest'
    ,'remote_recovery_file_dest'
    ,'standby_archive_dest'
    )
        AND value IS NOT NULL
        AND inst_id=to_number(sys_context('USERENV','INSTANCE'))
    union all
    SELECT name,case when instr(value,'.',-1)>0 then substr(value,1,instr(value,'/',-1)-1) else value end as folder
    FROM gv$parameter2
    WHERE 
        name like 'log_archive_dest%'
        AND name like 'db_create_online_log_dest%'    
        AND name not like 'log_archive_dest_state%'
        AND value IS NOT NULL
        AND inst_id=to_number(sys_context('USERENV','INSTANCE'))
    union all        
    SELECT 'data file' as name,case when instr(file_name,'.',-1)>0 then substr(file_name,1,instr(file_name,'/',-1)-1) else file_name end as folder 
    FROM dba_data_files
    union all
    SELECT 'temp file' as name,case when instr(file_name,'.',-1)>0 then substr(file_name,1,instr(file_name,'/',-1)-1) else file_name end as folder 
    FROM dba_temp_files
    union all
    SELECT 'redo log file' as name,case when instr(member,'.',-1)>0 then substr(member,1,instr(member,'/',-1)-1) else member end as folder 
    FROM gv$logfile WHERE inst_id=to_number(sys_context('USERENV','INSTANCE'))
    union all
    SELECT 'block change tracking' as name,case when instr(filename,'.',-1)>0 then substr(filename,1,instr(filename,'/',-1)-1) else filename end as folder 
    FROM v$block_change_tracking
    union all
    SELECT 'flashback database logfile' as name,case when instr(f.name,'.',-1)>0 then substr(f.name,1,instr(f.name,'/',-1)-1) else f.name end as folder 
    FROM gv$flashback_database_logfile f WHERE f.inst_id=to_number(sys_context('USERENV','INSTANCE'))
    union all
    SELECT DISTINCT 'tde folder' as name,wrl_parameter as value FROM gv$encryption_wallet WHERE wrl_parameter IS NOT NULL AND inst_id=to_number(sys_context('USERENV','INSTANCE'))
)
ORDER BY 
    1
;

prompt Check the listener files in $ORACLE_HOME/network/admin also
prompt by example :
prompt lsnrctl status LISTENER_DB11G|grep 'Listener Log File'
prompt lsnrctl status LISTENER_DB11G|grep 'Listener Parameter File'
prompt
prompt Execute this script in the pdbs also
prompt

@rest_sqp_set
