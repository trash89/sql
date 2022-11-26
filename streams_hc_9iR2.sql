set markup html off spool on

REM Do not use this script on Oracle10g Streams configurations.

connect / as sysdba

alter session set nls_date_format='HH24:Mi:SS MM/DD';
select 'STREAMS Health Check for '||global_name||' (Instance='||instance_name||') generated '||sysdate||' Version 1.6.10' o  from global_name, v$instance;

set lines 132
set numf 9999999999999
set pages 9999
col apply_database_link HEAD 'Database Link|for Remote|Apply' format a15

prompt ============================================================================================
prompt
prompt ++ DATABASE INFORMATION ++
COL MIN_LOG FORMAT A7
COL PK_LOG FORMAT A6
COL UI_LOG FORMAT A6
COL FORCE_LOG FORMAT A10
col archive_change# format 99999999999999
col archivelog_change# format 99999999999999
COL NAME HEADING 'Name'

SELECT DBid,name,created,
SUPPLEMENTAL_LOG_DATA_MIN MIN_LOG,SUPPLEMENTAL_LOG_DATA_PK PK_LOG,
SUPPLEMENTAL_LOG_DATA_UI UI_LOG, FORCE_LOGGING FORCE_LOG, 
resetlogs_time,log_mode, archive_change#,
open_mode,database_role,archivelog_change# from v$database;

prompt ============================================================================================
prompt
prompt ++ INSTANCE INFORMATION ++
col host format a20 wrap 
select instance_number INSTANCE, instance_name NAME, HOST_NAME HOST, VERSION,
STARTUP_TIME, STATUS, PARALLEL, ARCHIVER,LOGINS, SHUTDOWN_PENDING, INSTANCE_ROLE, ACTIVE_STATE  from Gv$instance;

prompt ============================================================================================
prompt
prompt ++ REGISTRY INFORMATION ++
col comp_id format a10 wrap
col comp_name format a35 wrap
col version format a10 wrap
col schema format a10

select comp_id, comp_name,version,status,modified,schema from DBA_REGISTRY;

prompt ============================================================================================
prompt
prompt ++ NLS DATABASE PARAMETERS ++
col parameter format a30 wrap
col value format a30 wrap

select * from NLS_DATABASE_PARAMETERS;

prompt ============================================================================================
prompt
prompt ++ GLOBAL NAME ++


select global_name from global_name;

prompt
prompt ============================================================================================
prompt
prompt ++ Key Init.ORA parameters ++
prompt
col name format a30
col value format a15
col description format a60 wrap

select name,value,description from v$parameter where name in
   ('aq_tm_processes', 'archive_lag_target', 'job_queue_processes',
    'shared_pool_size', 'sga_max_size', 'global_names', 'compatible',
    'log_parallelism', 'logmnr_max_persistent_sessions', 'transaction_auditing',
    'parallel_max_servers', 'processes', 'sessions','_first_spare_parameter','_kghdsidx_count'
    );

prompt
prompt ============================================================================================

prompt 
prompt ++ STREAMS QUEUES IN DATABASE ++
prompt ==========================================================================================
prompt
COLUMN OWNER HEADING 'Owner' FORMAT A10
COLUMN NAME HEADING 'Queue Name' FORMAT A30
COLUMN QUEUE_TABLE HEADING 'Queue Table' FORMAT A30
COLUMN ENQUEUE_ENABLED HEADING 'Enqueue|Enabled' FORMAT A7
COLUMN DEQUEUE_ENABLED HEADING 'Dequeue|Enabled' FORMAT A7
COLUMN USER_COMMENT HEADING 'Comment' FORMAT A20
COLUMN OWNER_INSTANCE HEADING 'Owner|Instance'

SELECT q.OWNER, q.NAME, t.QUEUE_TABLE, t.owner_instance, q.enqueue_enabled, 
  q.dequeue_enabled,q.USER_COMMENT
  FROM DBA_QUEUES q, DBA_QUEUE_TABLES t
  WHERE t.OBJECT_TYPE = 'SYS.ANYDATA' AND
        q.QUEUE_TABLE = t.QUEUE_TABLE AND
        q.OWNER       = t.OWNER;

prompt =========================================================================================
prompt
prompt ++ MESSAGES IN BUFFER QUEUE ++
col QUEUE format a50 wrap
col "Message Count" format 99999999999 heading 'Number of|Messages|in Queue'

SELECT distinct q.owner||'.'||q.name QUEUE, x.bufqm_nmsg "Message Count"from dba_queues q , x$bufqm x 
where  x.bufqm_qid=q.qid;

-- prompt =========================================================================================
prompt
-- prompt ++ BUFFER QUEUE SPILLOVER ++
-- select count(*) from AQ$_queuetablename_P;

prompt =========================================================================================
prompt
prompt ++ Minimum Archive Log Necessary to Restart Capture ++
prompt 
set serveroutput on
DECLARE
 hScn number := 0;
 lScn number := 0;
 sScn number;
 ascn number;
 alog varchar2(1000);
begin
  select min(start_scn), min(applied_scn) into sScn, ascn
    from dba_capture ;

/*
  if rScn != 0 then
    if rScn < ascn then
       ascn := rScn;
    end if;
  end if;

*/
  DBMS_OUTPUT.ENABLE(2000); 

  for cr in (select distinct(a.ckpt_scn)
             from system.logmnr_restart_ckpt$ a
             where a.ckpt_scn <= ascn and a.valid = 1
             and exists (select * from system.logmnr_log$ l
               where a.ckpt_scn between l.first_change# and l.next_change#)
             order by a.ckpt_scn desc)
  loop
    if (hScn = 0) then
       hScn := cr.ckpt_scn;
    else
       lScn := cr.ckpt_scn;
       exit;
    end if;
  end loop;

  if lScn = 0 then
    lScn := sScn;
  end if;
   select min(name) into alog from v$archived_log where lScn between first_change# and next_change#
;
  dbms_output.put_line('Capture will restart from SCN ' || lScn ||' in log '||alog);
end;
/


prompt ============================================================================================

prompt
prompt  ++ CAPTURE PROCESSES IN DATABASE ++
-- col start_scn format 9999999999999999
-- col applied_scn format 9999999999999999
col QUEUE HEADING 'Queue' format a25 wrap
col RSN HEADING 'Rule Set'format a25 wrap


SELECT capture_name, queue_owner||'.'||queue_name QUEUE, rule_set_owner||'.'||rule_set_name RSN, status , start_scn, captured_scn, applied_scn
FROM DBA_CAPTURE;

prompt
prompt ++ CAPTURE PROCESS PARAMETERS ++
col CAPTURE_NAME format a30
col parameter format a20
col value format a20
break on capture_name

select * from dba_capture_parameters order by capture_name,PARAMETER;

prompt ============================================================================================
prompt
prompt ++ STREAMS CAPTURE RULES CONFIGURED WITH DBMS_STREAMS_ADM PACKAGE ++
col NAME Heading 'Capture Name' format a25 wrap
col object format a25 wrap
col source_database format a15 wrap
col RULE format a35 wrap
col TYPE format a15 wrap
col dml_condition format a40 wrap
break on name

select streams_name NAME,table_owner||'.'||table_name OBJECT, 
SOURCE_DATABASE, 
RULE_TYPE ||' TABLE RULE' TYPE ,
INCLUDE_TAGGED_LCR,  
rule_owner||'.'||rule_name RULE
from dba_streams_table_rules where streams_type = 'CAPTURE' 
UNION
select streams_name NAME,schema_name OBJECT,
SOURCE_DATABASE,
RULE_TYPE ||' SCHEMA RULE' TYPE ,
INCLUDE_TAGGED_LCR,
rule_owner||'.'||rule_name RULE
from dba_streams_schema_rules where streams_type = 'CAPTURE'
UNION
select streams_name NAME,' ' OBJECT,
SOURCE_DATABASE,
RULE_TYPE ||' GLOBAL RULE' TYPE ,
INCLUDE_TAGGED_LCR,
rule_owner||'.'||rule_name RULE
from dba_streams_GLOBAL_rules where streams_type = 'CAPTURE' order by name,object ;



prompt ++  STREAMS TABLE SUBSETTING RULES ++
col NAME Heading 'Capture Name' format a25 wraP
col object format A25 WRAP
col source_database format a15 wrap
col RULE format a35 wrap
col TYPE format a15 wrap
col dml_condition format a40 wrap
break on name

select streams_name NAME,table_owner||'.'||table_name OBJECT,
RULE_TYPE || 'TABLE RULE' TYPE,
rule_owner||'.'||rule_name RULE,
DML_CONDITION , SUBSETTING_OPERATION
from dba_streams_table_rules where streams_type = 'CAPTURE' and (dml_condition is not null or subsetting_operation is not null);

prompt
prompt ++ CAPTURE RULES BY RULE SET ++
col capture_name format a25 wrap
col RULE_SET format a25 wrap
col RULE_NAME format a25 wrap
col condition format a50 word
set long 1000 
break on rule_set

select c.capture_name, rsr.rule_set_owner||'.'||rsr.rule_set_name RULE_SET ,rsr.rule_owner||'.'||rsr.rule_name RULE_NAME, 
r.rule_condition CONDITION from
dba_rule_set_rules rsr, DBA_RULES r ,DBA_CAPTURE c
where rsr.rule_name = r.rule_name and rsr.rule_owner = r.rule_owner and 
rsr.rule_set_owner=c.rule_set_owner and rsr.rule_set_name=c.rule_set_name  and rsr.rule_set_name in 
(select rule_set_name from dba_capture) order by rsr.rule_set_owner,rsr.rule_set_name;


prompt
prompt ++ CAPTURE RULE TRANSFORMATIONS BY RULE SET ++
col RULE_SET format a25 wrap
col RULE_NAME format a25 wrap
col condition format a60 wrap
set long 1000
break on RULE_SET

col action_context_name format a32 wrap
col action_context_value format a32 wrap
select rsr.rule_set_owner||'.'||rsr.rule_set_name RULE_SET ,rsr.rule_owner||'.'||rsr.rule_name RULE_NAME, 
ac.nvn_name ACTION_CONTEXT_NAME, ac.nvn_value.accessvarchar2() ACTION_CONTEXT_VALUE   from
dba_rule_set_rules rsr, dba_rules r, table(r.rule_action_context.actx_list) ac
where rsr.rule_name = r.rule_name and rsr.rule_owner = r.rule_owner and rule_set_name in 
(select rule_set_name from dba_capture) order by rsr.rule_set_owner,rsr.rule_set_name;

prompt ============================================================================================
prompt
prompt ++  TABLES PREPARED FOR CAPTURE ++
col table_name format a30
select * from dba_capture_prepared_tables;

prompt ++  SCHEMAS PREPARED FOR CAPTURE ++
 
select * from dba_capture_prepared_schemas;

prompt ++ DATABASE PREPARED FOR CAPTURE ++

select * from dba_capture_prepared_database;

prompt ============================================================================================
prompt
prompt ++  TABLES WITH SUPPLEMENTAL LOGGING  ++
col OWNER format a30 wrap
col table_name format a30 wrap

select distinct owner,table_name from dba_log_groups;


prompt
prompt ++  TABLE LEVEL SUPPLEMENTAL LOG GROUPS ENABLED FOR CAPTURE ++
col object format a40 wrap
col column_name format a30 wrap
col log_group_name format a25 wrap

select owner||'.'||table_name OBJECT, log_group_name, 
   decode(always,'ALWAYS','Unconditional',NULL,'Conditional') ALWAYS from dba_log_groups;

prompt ++ SUPPLEMENTALLY LOGGED COLUMNS ++

select owner||'.'||table_name OBJECT, log_group_name, column_name,position from dba_log_group_columns;

prompt ============================================================================================
prompt
prompt ++ CAPTURE STATISTICS ++
COLUMN PROCESS_NAME HEADING "Capture|Process|Number" FORMAT A7
COLUMN CAPTURE_NAME HEADING 'Capture|Name' FORMAT A10
COLUMN SID HEADING 'Session|ID' FORMAT 9999
COLUMN SERIAL# HEADING 'Session|Serial|Number' FORMAT 9999
COLUMN STATE HEADING 'State' FORMAT A17
COLUMN TOTAL_MESSAGES_CAPTURED HEADING 'Redo Entries|Scanned'  FORMAT 9999999999999999
COLUMN TOTAL_MESSAGES_ENQUEUED HEADING 'Total|LCRs|Enqueued'  FORMAT 9999999999999999

COLUMN LATENCY_SECONDS HEADING 'Latency|Seconds' FORMAT 99999999
COLUMN CREATE_TIME HEADING 'Event Creation|Time' FORMAT A19
COLUMN ENQUEUE_TIME HEADING 'Last|Enqueue |Time' FORMAT A19
COLUMN ENQUEUE_MESSAGE_NUMBER HEADING 'Last Queued|Message Number' FORMAT 9999999999999999
COLUMN ENQUEUE_MESSAGE_CREATE_TIME HEADING 'Last Queued|Message|Create Time'FORMAT A19
COLUMN CAPTURE_MESSAGE_CREATE_TIME HEADING 'Last Redo|Message|Create Time' FORMAT A19
COLUMN CAPTURE_MESSAGE_NUMBER HEADING 'Last Redo|Message Number' FORMAT 9999999999999999
COLUMN STARTUP_TIME HEADING 'Startup Timestamp' FORMAT A19

COLUMN MSG_STATE HEADING 'Message State' FORMAT A13
COLUMN CONSUMER_NAME HEADING 'Consumer' FORMAT A30

COLUMN PROPAGATION_NAME HEADING 'Propagation' FORMAT A8
COLUMN START_DATE HEADING 'Start Date'
COLUMN PROPAGATION_WINDOW HEADING 'Duration' FORMAT 99999
COLUMN NEXT_TIME HEADING 'Next|Time' FORMAT A8
COLUMN LATENCY HEADING 'Latency|Seconds' FORMAT 99999999

-- ALTER session set nls_date_format='HH24:MI:SS MM/DD/YY';

SELECT SUBSTR(s.PROGRAM,INSTR(S.PROGRAM,'(')+1,4) PROCESS_NAME,
       c.CAPTURE_NAME,
       c.SID,
       c.SERIAL#,
       c.STATE,
       c.startup_time,
       c.TOTAL_MESSAGES_CAPTURED,
       c.TOTAL_MESSAGES_ENQUEUED
  FROM GV$STREAMS_CAPTURE c, GV$SESSION s
  WHERE c.SID = s.SID AND
        c.SERIAL# = s.SERIAL#;

SELECT capture_name, 
   SYSDATE "Current Time",
   capture_time "Capture Process TS",
   capture_message_number,
   capture_message_create_time ,
   enqueue_message_number,
   enqueue_message_create_time ,
   enqueue_time   
FROM GV$STREAMS_CAPTURE;


prompt
prompt ==========================================================================================
prompt
prompt ++ PROPAGATION JOBS IN DATABASE ++
prompt =========================================================================================
prompt
COLUMN 'Source Queue' FORMAT A39
COLUMN 'Destination Queue' FORMAT A39
COLUMN PROPAGATION_NAME HEADING 'Propagation' FORMAT A35


SELECT p.propagation_name, p.SOURCE_QUEUE_OWNER ||'.'|| 
   p.SOURCE_QUEUE_NAME ||'@'|| 
   g.GLOBAL_NAME "Source Queue", 
   p.DESTINATION_QUEUE_OWNER ||'.'|| 
   p.DESTINATION_QUEUE_NAME ||'@'||
   p.DESTINATION_DBLINK "Destination Queue"
   FROM DBA_PROPAGATION p, GLOBAL_NAME g;

prompt
prompt ++ PROPAGATION RULE SETS IN DATABASE ++
prompt
COLUMN PROPAGATION_NAME HEADING 'Propagation' FORMAT A35
COLUMN RULE_SET_OWNER HEADING 'Rule Set Owner' FORMAT A35
COLUMN RULE_SET_NAME HEADING 'Rule Set Name' FORMAT A35

SELECT PROPAGATION_NAME, RULE_SET_OWNER, RULE_SET_NAME 
  FROM DBA_PROPAGATION;

prompt ============================================================================================
prompt
prompt ++ STREAMS PROPAGATION RULES CONFIGURED WITH DBMS_STREAMS_ADM PACKAGE ++
col NAME Heading 'Name' format  a25 wrap
col PropNAME format a25 Heading 'Propagation Name'
col object format a25 wrap
col source_database format a15 wrap
col RULE format a35 wrap
col TYPE format a15 wrap
col dml_condition format a40 wrap
break on name

select streams_name PropNAME,table_owner||'.'||table_name OBJECT,
SOURCE_DATABASE,
RULE_TYPE ||' TABLE RULE' TYPE ,
INCLUDE_TAGGED_LCR,
rule_owner||'.'||rule_name RULE
from dba_streams_table_rules where streams_type = 'PROPAGATION'
UNION
select streams_name PropNAME,schema_name OBJECT,
SOURCE_DATABASE,
RULE_TYPE ||' SCHEMA RULE' TYPE ,
INCLUDE_TAGGED_LCR,
rule_owner||'.'||rule_name RULE
from dba_streams_schema_rules where streams_type = 'PROPAGATION'
UNION
select streams_name PropNAME,' ' OBJECT,
SOURCE_DATABASE,
RULE_TYPE ||' GLOBAL RULE' TYPE ,
INCLUDE_TAGGED_LCR,
rule_owner||'.'||rule_name RULE
from dba_streams_GLOBAL_rules where streams_type = 'PROPAGATION' order by PropNAME,object;



prompt ++  STREAMS TABLE SUBSETTING RULES ++
col NAME format a25 wraP
col object format A25 WRAP
col source_database format a15 wrap
col RULE format a35 wrap
col TYPE format a15 wrap
col dml_condition format a40 wrap
break on name

select streams_name NAME,table_owner||'.'||table_name OBJECT,
RULE_TYPE || 'TABLE RULE' TYPE,
rule_owner||'.'||rule_name RULE,
DML_CONDITION , SUBSETTING_OPERATION
from dba_streams_table_rules where streams_type = 'PROPAGATION' and (dml_condition is not null or subsetting_operation is not null);

prompt
prompt ++ PROPAGATION  RULES BY RULE SET ++
prompt
col RULE_SET format a25 wrap
col RULE_NAME format a25 wrap
col condition format a60 wrap
set long 1000
break on RULE_SET

set long 1000
select rsr.rule_set_owner||'.'||rsr.rule_set_name RULE_SET ,rsr.rule_owner||'.'||rsr.rule_name RULE_NAME,
r.rule_condition CONDITION from
dba_rule_set_rules rsr, dba_rules r
where rsr.rule_name = r.rule_name and rsr.rule_owner = r.rule_owner and rule_set_name in
(select rule_set_name from dba_propagation) order by rsr.rule_set_owner,rsr.rule_set_name
/
prompt
prompt ++ PROPAGATION RULE TRANSFORMATIONS BY RULE SET ++
col RULE_SET format a25 wrap
col RULE_NAME format a25 wrap
col action_context_name format a32 wrap
col action_context_value format a32 wrap
break on RULE_SET

select rsr.rule_set_owner||'.'||rsr.rule_set_name RULE_SET ,rsr.rule_owner||'.'||rsr.rule_name RULE_NAME,
ac.nvn_name ACTION_CONTEXT_NAME, ac.nvn_value.accessvarchar2() ACTION_CONTEXT_VALUE   from
dba_rule_set_rules rsr, dba_rules r, table(r.rule_action_context.actx_list) ac
where rsr.rule_name = r.rule_name and rsr.rule_owner = r.rule_owner and rule_set_name in
(select rule_set_name from dba_propagation) order by rsr.rule_set_owner,rsr.rule_set_name
/
prompt =========================================================================================
prompt
prompt ++ SCHEDULE FOR EACH PROPAGATION++
prompt =========================================================================================
prompt
COLUMN START_DATE HEADING 'Start Date'
COLUMN PROPAGATION_WINDOW HEADING 'Duration|in Seconds' FORMAT 99999
COLUMN NEXT_TIME HEADING 'Next|Time' FORMAT A8
COLUMN LATENCY HEADING 'Latency|in Seconds' FORMAT 99999
COLUMN SCHEDULE_DISABLED HEADING 'Status' FORMAT A8
COLUMN PROCESS_NAME HEADING 'Process' FORMAT A8
COLUMN FAILURES HEADING 'Number of|Failures' FORMAT 99
COLUMN LAST_ERROR_MSG HEADING 'Error Message' FORMAT A50 
COLUMN CURRENT_START_DATE HEADING 'Current|Start' FORMAT A17
COLUMN LAST_RUN_DATE HEADING 'Last|Run' FORMAT A17
COLUMN NEXT_RUN_DATE HEADING 'Next|Run' FORMAT A17
COLUMN LAST_ERROR_DATE HEADING 'Last|Error' FORMAT A17



SELECT p.propagation_name,TO_CHAR(s.START_DATE, 'HH24:MI:SS MM/DD/YY') START_DATE,
       s.PROPAGATION_WINDOW, 
       s.NEXT_TIME, 
       s.LATENCY,
       DECODE(s.SCHEDULE_DISABLED,
                'Y', 'Disabled',
                'N', 'Enabled') SCHEDULE_DISABLED,
       s.PROCESS_NAME,
       s.FAILURES,
       s.LAST_ERROR_MSG
  FROM DBA_QUEUE_SCHEDULES s, DBA_PROPAGATION p
  WHERE   p.DESTINATION_DBLINK = s.DESTINATION
  AND s.SCHEMA = p.SOURCE_QUEUE_OWNER
  AND s.QNAME = p.SOURCE_QUEUE_NAME;

SELECT p.propagation_name, TO_CHAR(s.LAST_RUN_DATE, 'HH24:MI:SS MM/DD/YY') LAST_RUN_DATE,
   TO_CHAR(s.CURRENT_START_DATE, 'HH24:MI:SS MM/DD/YY') CURRENT_START_DATE, 
   TO_CHAR(s.NEXT_RUN_DATE, 'HH24:MI:SS MM/DD/YY') NEXT_RUN_DATE, 
   TO_CHAR(s.LAST_ERROR_DATE, 'HH24:MI:SS MM/DD/YY') LAST_ERROR_DATE
  FROM DBA_QUEUE_SCHEDULES s, DBA_PROPAGATION p
  WHERE   p.DESTINATION_DBLINK = s.DESTINATION
  AND s.SCHEMA = p.SOURCE_QUEUE_OWNER
  AND s.QNAME = p.SOURCE_QUEUE_NAME;

prompt
prompt ++ EVENTS AND BYTES PROPAGATED FOR EACH PROPAGATION++
prompt
COLUMN TOTAL_TIME HEADING 'Total Time Executing|in Seconds' FORMAT 999999
COLUMN TOTAL_NUMBER HEADING 'Total Events Propagated' FORMAT 999999999
COLUMN TOTAL_BYTES HEADING 'Total Bytes Propagated' FORMAT 9999999999999

SELECT p.propagation_name, s.TOTAL_TIME, s.TOTAL_NUMBER, s.TOTAL_BYTES 
  FROM DBA_QUEUE_SCHEDULES s, DBA_PROPAGATION p
  WHERE   p.DESTINATION_DBLINK = s.DESTINATION
  AND s.SCHEMA = p.SOURCE_QUEUE_OWNER
  AND s.QNAME = p.SOURCE_QUEUE_NAME;

prompt ============================================================================================

prompt
prompt ++ APPLY INFORMATION ++
col apply_name format a25 wrap heading 'Apply|Name'
col queue format a25 wrap heading 'Queue|Name'
col apply_tag format a7 wrap  heading 'Apply|Tag'
col ruleset format a25 wrap heading 'Rule Set|Name'
col apply_user format a15 wrap heading 'Apply|User'
col apply_captured format a15 wrap heading 'Captured or|User Enqueued'
col apply_database_link HEADING 'Remote Apply|Database Link' format a25 wrap

Select apply_name,queue_owner||'.'||queue_name QUEUE,
DECODE(APPLY_CAPTURED,
                'YES', 'Captured',
                'NO',  'User-Enqueued') APPLY_CAPTURED,status, 
apply_user, apply_tag, rule_set_owner||'.'||rule_set_name RULESET, apply_database_link from DBA_APPLY;

prompt
prompt ++ APPLY PROCESS PARAMETERS ++

col APPLY_NAME format a30
col parameter format a20
col value format a20
break on apply_name

select * from dba_apply_parameters order by apply_name,parameter;

prompt ============================================================================================
prompt
prompt ++ STREAMS APPLY RULES CONFIGURED WITH DBMS_STREAMS_ADM PACKAGE ++
col NAME format a25 wrap heading 'Streams|Name'
col object format a25 wrap heading 'Database|Object'
col source_database format a15 wrap heading 'Source|Database'
col RULE format a35 wrap heading 'Rule|Name'
col TYPE format a15 wrap heading 'Rule|Type'
col dml_condition format a40 wrap heading 'Rule|Condition'


select streams_name NAME,table_owner||'.'||table_name OBJECT,
SOURCE_DATABASE,
RULE_TYPE ||' TABLE RULE' TYPE ,
INCLUDE_TAGGED_LCR,
rule_owner||'.'||rule_name RULE
from dba_streams_table_rules where streams_type = 'APPLY'
UNION
select streams_name NAME,schema_name OBJECT,
SOURCE_DATABASE,
RULE_TYPE ||' SCHEMA RULE' TYPE ,
INCLUDE_TAGGED_LCR,
rule_owner||'.'||rule_name RULE
from dba_streams_schema_rules where streams_type = 'APPLY'
UNION
select streams_name NAME,' ' OBJECT,
SOURCE_DATABASE,
RULE_TYPE ||' GLOBAL RULE' TYPE ,
INCLUDE_TAGGED_LCR,
rule_owner||'.'||rule_name RULE
from dba_streams_GLOBAL_rules where streams_type = 'APPLY' order by name,object;

prompt ++  STREAMS TABLE SUBSETTING RULES ++
col NAME format a25 wraP
col object format A25 WRAP
col source_database format a15 wrap
col RULE format a35 wrap
col TYPE format a15 wrap
col dml_condition format a40 wrap
break on name

select streams_name NAME,table_owner||'.'||table_name OBJECT,
RULE_TYPE || 'TABLE RULE' TYPE,
rule_owner||'.'||rule_name RULE,
DML_CONDITION , SUBSETTING_OPERATION
from dba_streams_table_rules where streams_type = 'APPLY' and (dml_condition is not null or subsetting_operation is not null);

prompt

prompt ++ APPLY Rules ++
prompt
prompt ++ APPLY RULES BY RULE SET ++
col RULE_SET format a25 wrap
col RULE_NAME format a25 wrap
col condition format a60 wrap
set long 1000
break on RULE_SET

select rsr.rule_set_owner||'.'||rsr.rule_set_name RULE_SET ,rsr.rule_owner||'.'||rsr.rule_name RULE_NAME,
r.rule_condition CONDITION from
dba_rule_set_rules rsr, dba_rules r
where rsr.rule_name = r.rule_name and rsr.rule_owner = r.rule_owner and rule_set_name in
(select rule_set_name from dba_apply) order by rsr.rule_set_owner,rsr.rule_set_name
/
prompt
prompt ++ APPLY RULE TRANSFORMATIONS BY RULE SET ++
col action_context_name format a32 wrap
col action_context_value format a32 wrap
col RULE_SET format a25 wrap
col RULE_NAME format a25 wrap
col condition format a60 wrap
set long 1000
break on RULE_SET

select rsr.rule_set_owner||'.'||rsr.rule_set_name RULE_SET ,rsr.rule_owner||'.'||rsr.rule_name RULE_NAME,
ac.nvn_name ACTION_CONTEXT_NAME, ac.nvn_value.accessvarchar2() ACTION_CONTEXT_VALUE   from
dba_rule_set_rules rsr, dba_rules r, table(r.rule_action_context.actx_list) ac
where rsr.rule_name = r.rule_name and rsr.rule_owner = r.rule_owner and rule_set_name in
(select rule_set_name from dba_apply) order by rsr.rule_set_owner,rsr.rule_set_name
/


prompt ============================================================================================
prompt
prompt ++ APPLY HANDLERS ++
col apply_name format a25 wrap
col message_handler format a25 wrap
col ddl_handler format a25 wrap

select apply_name, message_handler, ddl_handler from dba_apply where message_handler is not null or ddl_handler is not null;

prompt
prompt ++ APPLY DML HANDLERS ++
col object format a25 wrap
col user_procedure format a40 wrap
col dblink format a15 wrap
col operation_name format a1
col typ format a3 wrap

select object_owner||'.'||object_name OBJECT, substr(Operation_name,1,1) , 
user_procedure,
decode(error_handler,'Y','Error','N','DML','UNKNOWN') TYP, APPLY_Database_link DBLINK 
from dba_apply_dml_handlers ;

prompt
prompt ++ DML HANDLER STATUS ++
prompt
col user_procedure format a40 wrap

select distinct h.user_procedure, 
    o.status, o.object_type, o.created, o.last_ddl_time
    from dba_objects o, dba_apply_dml_handlers h where o.owner=substr(h.user_procedure,1,instr(h.user_procedure,'.',1,1)-1) and 
    o.object_name = substr(h.user_procedure,instr(h.user_procedure,'.',-1,1)+1);

prompt
prompt ++ RULE TRANSFORMATIONS STATUS ++
col action_context_name format a32 wrap
col action_context_value format a32 wrap
col RULE_SET format a25 wrap
col RULE_NAME format a25 wrap
col condition format a60 wrap
set long 1000
break on RULE_SET

select distinct
   ac.nvn_value.accessvarchar2() ACTION_CONTEXT_VALUE,
    o.status, o.object_type, o.created, o.last_ddl_time
    from dba_objects o, 
    dba_rules r, table(r.rule_action_context.actx_list) ac
   where 
    o.owner=upper(substr(ac.nvn_value.accessvarchar2(),1,instr(ac.nvn_value.accessvarchar2(),'.',1,1)-1)) and 
    o.object_name = upper(substr(ac.nvn_value.accessvarchar2(),instr(ac.nvn_value.accessvarchar2(),'.',-1,1)+1))
/

prompt ============================================================================================
prompt
prompt ++ UPDATE CONFLICT RESOLUTION COLUMNS ++

col object format a25 wrap
col method_name heading 'Method' format a12
col resolution_column heading 'Resolution|Column' format a13
col column heading 'Column Name' format a30

select object_owner||'.'||object_name object, method_name,
resolution_column, column_name 
from dba_apply_conflict_columns order by object_owner,object_name;

prompt ============================================================================================
prompt
prompt ++ KEY COLUMNS SET FOR APPLY ++

select * from dba_apply_key_columns;

prompt ============================================================================================
prompt
prompt ++ APPLY STATISTICS ++
prompt
prompt ============================================================================================

prompt
prompt ++ APPLY Reader Statistics ++
SELECT ap.APPLY_NAME,
       DECODE(ap.APPLY_CAPTURED,
                'YES','Captured LCRS',
                'NO','User-Enqueued','UNKNOWN') APPLY_CAPTURED,
       SUBSTR(s.PROGRAM,INSTR(S.PROGRAM,'(')+1,4) PROCESS_NAME,
       r.STATE, 
       r.TOTAL_MESSAGES_DEQUEUED, 
       r.sga_used
       FROM V$STREAMS_APPLY_READER r, V$SESSION s, DBA_APPLY ap
       WHERE r.SID = s.SID AND
             r.SERIAL# = s.SERIAL# AND
             r.APPLY_NAME = ap.APPLY_NAME;

SELECT APPLY_NAME,
       (DEQUEUE_TIME-DEQUEUED_MESSAGE_CREATE_TIME)*86400 LATENCY,
     TO_CHAR(DEQUEUED_MESSAGE_CREATE_TIME,'HH24:MI:SS MM/DD') CREATION,
     TO_CHAR(DEQUEUE_TIME,'HH24:MI:SS MM/DD') LAST_DEQUEUE,
     DEQUEUED_MESSAGE_NUMBER
  FROM V$STREAMS_APPLY_READER;

prompt ============================================================================================
prompt
prompt ++ APPLY Coordinator Statistics ++
col apply_name format a22 wrap
col process_name format a7
col RECEIVED format 99999999
col ASSIGNED format 99999999
col APPLIED format 99999999
col ERRORS format 99999999
col WAIT_DEPS format 99999999
col WAIT_COMMITS format 99999999

SELECT ap.APPLY_NAME,
       SUBSTR(s.PROGRAM,INSTR(S.PROGRAM,'(')+1,4) PROCESS,
       c.STATE,
       c.TOTAL_RECEIVED RECEIVED,
       c.TOTAL_ASSIGNED ASSIGNED,
       c.TOTAL_APPLIED APPLIED,
       c.TOTAL_ERRORS ERRORS,
       c.TOTAL_WAIT_DEPS WAIT_DEPS, c.TOTAL_WAIT_COMMITS WAIT_COMMITS
       FROM GV$STREAMS_APPLY_COORDINATOR  c, GV$SESSION s, DBA_APPLY ap
       WHERE c.SID = s.SID AND
             c.SERIAL# = s.SERIAL# AND
             c.APPLY_NAME = ap.APPLY_NAME;


SELECT APPLY_NAME,
     LWM_MESSAGE_CREATE_TIME LWM_MSG_TS ,
     LWM_MESSAGE_NUMBER LWM_MSG_NBR ,
     LWM_TIME LWM_UPDATED,
     HWM_MESSAGE_CREATE_TIME HWM_MSG_TS,
     HWM_MESSAGE_NUMBER HWM_MSG_NBR ,
     HWM_TIME HWM_UPDATED
  FROM GV$STREAMS_APPLY_COORDINATOR;

prompt ============================================================================================
prompt
prompt  ++ APPLY Server Statistics ++
col SRVR format 9999
col ASSIGNED format 99999999
col APPLIED format 99999999
col MESSAGE_SEQUENCE format 9999999


SELECT ap.APPLY_NAME,
       SUBSTR(s.PROGRAM,INSTR(S.PROGRAM,'(')+1,4) PROCESS_NAME,
       a.server_id SRVR,
       a.STATE,
       a.TOTAL_ASSIGNED ASSIGNED,
       a.TOTAL_MESSAGES_APPLIED APPLIED,
       a.APPLIED_MESSAGE_NUMBER, 
       a.APPLIED_MESSAGE_CREATE_TIME ,
       a.MESSAGE_SEQUENCE
       FROM GV$STREAMS_APPLY_SERVER a, GV$SESSION s, DBA_APPLY ap
       WHERE a.SID = s.SID AND
             a.SERIAL# = s.SERIAL# AND
             a.APPLY_NAME = ap.APPLY_NAME;

col current_txn format a15 wrap
col dependent_txn format a15 wrap

select APPLY_NAME, server_id SRVR,
xidusn||'.'||xidslt||'.'||xidsqn CURRENT_TXN,
commitscn,
dep_xidusn||'.'||dep_xidslt||'.'||dep_xidsqn DEPENDENT_TXN,
dep_commitscn
from  Gv$streams_apply_server order by apply_name,server_id;

prompt  ++  APPLY PROGRESS ++

select * from dba_apply_progress;

prompt ============================================================================================
prompt
prompt ++  ERROR QUEUE ++
col source_commit_scn HEADING 'Source|Commit|Scn'

Select apply_name, source_database,source_commit_scn,message_number, message_count,
   local_transaction_id, error_message 
   from DBA_APPLY_ERROR order by apply_name ,source_commit_scn ;

prompt
prompt ============================================================================================
prompt
prompt ++ INSTANTIATION SCNs for APPLY TABLES ++
col source_database format a25 wrap
col object format a30
col instantiation_scn format 9999999999999999
col apply_database_link HEAD 'Database Link|for Remote|Apply' format a15

select source_database, source_object_owner||'.'||source_object_name OBJECT, 
   apply_database_link DBLINK, ignore_scn,
   instantiation_scn from dba_apply_instantiated_objects order by source_database, object;

prompt
prompt ++ INSTANTIATION SCNs for APPLY SCHEMA and  DATABASE ++

select source_db_name source_database, name OBJECT, 
   DBLINK, inst_scn, global_flag, spare1 
   from sys.apply$_source_schema order by source_database, object;

prompt
prompt ============================================================================================
prompt
prompt ++ DBA OBJECTS - Rules and Streams Processes ++
prompt
col OBJECT format a30 wrap heading 'Object'

select owner||'.'||object_name OBJECT,
    object_id,object_type,created,last_ddl_time, status from
    dba_objects where object_type in ('RULE','RULE SET','UNDEFINED');

prompt
prompt ============================================================================================
prompt

REM  This script does sanity checking of STREAMS objects compared to the underlying RULES.
REM  It is assumed that the DBMS_STREAMS_ADM package procedures
REM     ADD_TABLE_RULES
REM     ADD_SCHEMA_RULES
REM     ADD_GLOBAL_RULES
REM  have been used to configure streams.

prompt
prompt ++     SUSPICIOUS   RULES   ++
prompt
col object format a30 wrap
col rule format a30 wrap

REM create a temporary table (PHM_STREAMS_RULES)  to simplify the queries 

create table phm_streams_rules as 
   select rule_owner,rule_name,rule_condition,source_database,table_owner,table_name,
   rule_type,streams_type,streams_name from dba_streams_table_rules ;
insert into phm_streams_rules  select rule_owner,rule_name,rule_condition,source_database,
   schema_name table_name,null, rule_type, streams_type,streams_name from dba_streams_schema_rules;
insert into phm_streams_rules  select rule_owner,rule_name,rule_condition,source_database,
  'GLOBAL_RULE','GLOBAL_RULE',rule_type, streams_type ,streams_name from dba_streams_global_rules;


prompt ++ MISSING RULES IN DBA_RULES ++
prompt   Rows are returned if a rule is defined in DBA_STREAMS_TABLE_RULES (or SCHEMA, GLOBAL, too)
prompt   but does not exist in the DBA_RULES view.
prompt

select rule_owner,rule_name from phm_streams_rules 
MINUS
select rule_owner,rule_name from dba_rules;

prompt ++ EXTRA RULES IN DBA_RULES ++
prompt   Rows are returned if a rule is defined in the DBA_RULES view 
prompt   but does not exist in the DBA_STREAMS_TABLE_RULES (or SCHEMA, GLOBAL, too) view.
prompt
select rule_owner,rule_name from dba_rules 
MINUS 
select rule_owner,rule_name from phm_streams_rules;

prompt ++ RULE_CONDITIONS DO NOT MATCH BETWEEN STREAMS AND RULES ++
prompt   Rows are returned if the rule condition is different between the DBA_STREAMS_TABLE_RULES view
prompt   and the DBA_RULES view.  This indicates that a manual modification has been performed on the 
prompt   underlying rule.  DBA_STREAMS_TABLE_RULES always shows the initial configuration rule condition. 
prompt

select s.streams_type, s.streams_name, r.rule_owner||'.'||r.rule_name RULE,r.rule_condition 
  from phm_streams_rules s, dba_rules r
  where r.rule_name=s.rule_name and r.rule_owner=s.rule_owner and 
  s.rule_condition != dbms_lob.substr(r.rule_condition);

prompt ++ SOURCE DATABASE NAME DOES NOT MATCH FOR CAPTURE OR PROPAGATION RULES ++
prompt   Rows are returned if the source database column in the  DBA_STREAMS_TABLE_RULES view
prompt   for capture and/or propagation defined at this site does not match the 
prompt   global_name of this site.  For capture rules, the source database must match the global_name
prompt   of database.  FOr propagation rules, the source database name will typically be the 
prompt   global name of the database.  In some cases, it may be correct to have a different source
prompt   database name from the global name.  For example, at an intermediate node between a source site
prompt   and the ultimate target site, the rule source database name field will be diferent from the local
prompt   global name of the intermediate site.
prompt

select streams_type, streams_name, r.rule_owner||'.'||r.rule_name RULE from phm_streams_rules r
where source_database is not null and source_database != (select global_name from global_name) and streams_type in ('CAPTURE','PROPAGATION');

prompt ++ GLOBAL RULE FOR CAPTURE SPECIFIED BUT CONDITION NOT MODIFIED ++
rem  - It is assumed that GLOBAL rules for CAPTURE  must be modified because of the unsupported datatypes in 9iR2.
prompt   Rows are returned if a global rule is defined in the  DBA_STREAMS_GLOBAL_RULES view
prompt   and the rule condition in the DBA_RULES view has not been modified.  
prompt  In 9iR2, the GLOBAL rule must be modified to eliminate any unsupported datatypes.  For example,
prompt  the streams administrator schema must be eliminated from the capture rules.  Failure to do 
prompt  this will result in the abort of the capture process.

select streams_name,  r.rule_owner||'.'||r.rule_name RULE from phm_streams_rules s , dba_rules r
where streams_type = 'CAPTURE' and 
table_owner='GLOBAL_RULE' and table_name = 'GLOBAL_RULE' and
r.rule_name=s.rule_name and 
r.rule_owner=s.rule_owner and 
s.rule_condition = dbms_lob.substr(r.rule_condition);

prompt ++ No RULE SET DEFINED FOR CAPTURE ++
prompt
Prompt    Capture requires a rule set to be defined to assure that only supported datatypes are captured.
prompt

select capture_name from dba_capture where rule_set_name is null;


prompt ++ APPLY RULES WITH NO SOURCE DATABASE SPECIFIED
prompt   Rows are returned if no source database is specified in the DBA_STREAMS_TABLE_RULES 
prompt   (SCHEMA,GLOBAL) view.  An apply process can perform transactions from a single source database.  
prompt   In a typical replication environment, the source database name must be specified.  In the single
prompt   site case where captured events from the source database are handled by an apply process on the
prompt   same database, the source database column does not need to be specified. 
prompt

select streams_name,  s.rule_owner||'.'||s.rule_name RULE, s.table_owner||'.'|| s.table_name OBJECT
from phm_streams_rules s, dba_rules r
where s.streams_type = 'APPLY' and s.source_database is null and
r.rule_name=s.rule_name and
r.rule_owner=s.rule_owner and
s.rule_condition = dbms_lob.substr(r.rule_condition);

prompt ++ SCHEMA RULES FOR NON_EXISTANT SCHEMA ++

select s.streams_type, s.streams_name, s.rule_owner||'.'||s.rule_name RULE, s.table_owner,
ac.nvn_name ACTION_CONTEXT_NAME, ac.nvn_value.accessvarchar2() ACTION_CONTEXT_VALUE
from phm_streams_rules s , dba_rules r, dba_users u, table(r.rule_action_context.actx_list) ac
where s.table_name is null and u.username=s.table_owner 
and r.rule_owner=s.rule_owner and r.rule_name = s.rule_name and ac.nvn_value.accessvarchar2() is null;

prompt ++ TABLE RULES FOR NON_EXISTANT OBJECT ++

select  s.streams_type,streams_name,s.rule_owner||'.'||s.rule_name RULE, s.table_owner||'.'|| s.table_name OBJECT,
ac.nvn_name ACTION_CONTEXT_NAME, ac.nvn_value.accessvarchar2() ACTION_CONTEXT_VALUE
from phm_streams_rules s , dba_rules r, dba_objects o, table(r.rule_action_context.actx_list) ac
where o.object_name=s.table_name and o.owner=s.table_owner
and r.rule_owner=s.rule_owner and r.rule_name = s.rule_name and ac.nvn_value.accessvarchar2() is null;


prompt ++ CONSTRAINTS ON TABLES CONFIGURED IN STREAMS
prompt
col LAST_CHANGE format a11 word heading 'Last|Change'
col search_condition format a25 word heading 'Search|Condition'
col ref_constraint HEADING 'Reference|Constraint'

select  c.owner||'.'||c.table_name object,c.constraint_name,c.constraint_type, 
  status, LAST_CHANGE ,search_condition,r_owner||'.'||r_constraint_name Ref_constraint
  from dba_constraints c,dba_apply_instantiated_objects p where
  c.owner=p.source_object_owner and c.table_name=p.source_object_name and c.constraint_type in ('P','U','R','C')
  and  constraint_name not like 'SYS_IOT%' order by c.owner,c.table_name;

prompt ++ INDEXES on TABLES ++
col object format a40 HEADING 'Table'
col index_name format a40
col funcidx_status format a10
col index_type format a10

select table_owner||'.'||table_name object, table_type, index_name,index_type,funcidx_status from dba_indexes
where table_owner not in ('SYS','SYSTEM','CTX', 'CTXSYS','XDB');


prompt ++ UNSUPPORTED TABLES IN STREAMS
prompt   The list displayed gives an indication of unsupported tables in Streams
prompt

----------------------------------------------------------------------------
/*
** THE CASE STATEMENTS IN THE SELECT CLAUSE SHOULD BE IDENTICAL
** TO THE OR CLAUSES IN THE WHERE CLAUSE.
**
** This view lists unsupported tables in 9.2.
** tproperty, oflags, tflags are included for debugging.
*/
create or replace view PHM_STREAMS_UNSUPPORTED_9_2
  (owner, table_name, tproperty, ttrigflag, oflags, tflags, reason, compatible,
   auto_filtered)
as
  select
    distinct u.name, o.name,
             t.property, t.trigflag, o.flags, t.flags,
    (case
      when 
        ( (bitand(t.property, 
                64                                                    /* IOT */
              + 128         /* 0x00000080              IOT with row overflow */
              + 256         /* 0x00000100            IOT with row clustering */
              + 512         /* 0x00000200               iot OVeRflow segment */
             ) != 0
          ) or
          (bitand(t.flags,
                268435456    /* 0x10000000   IOT with Phys Rowid/mapping tab */
              + 536870912    /* 0x20000000 Mapping Tab for Phys rowid of IOT */
             ) != 0
          ) or
          (bitand(t.property, 262208) = 262208  /* 0x40+0x40000 IOT+user LOB */
          ) or
          (bitand(t.property, 2112) = 2112  /* 0x40+0x800 IOT + internal LOB */
          ) or
          (bitand(t.property, 64) != 0 and                           /* 0x40 */
             bitand(t.flags, 131072) != 0                         /* 0x20000 */
          )
        )
        then 'IOT'
      when bitand(t.property,
                  1                                           /* typed table */
                + 2                                           /* ADT columns */
                + 4                                  /* nested table columns */
                + 8                                           /* REF columns */
                + 16                                        /* array columns */
                + 4096                                             /* pk OID */
                + 8192              /* storage table for nested table column */
                + 65536                                              /* sOID */
               ) != 0
         then 'column with user-defined type'
      when (exists
            (select 1 
             from   sys.col$ c 
             where  t.obj# = c.obj#
               and
               ( (bitand(c.property, 32) = 32                      /* hidden */
                 ) or
                 (c.type# not in ( 
                     1,                                          /* varchar2 */
                     2,                                            /* number */
                     12,                                             /* date */
                     96,                                             /* char */
                     100,                                    /* binary float */
                     101,                                   /* binary double */
                     112,                                  /* clob and nclob */
                     113,                                            /* blob */
                     180,                                  /* timestamp (..) */
                     181,                    /* timestamp(..) with time zone */
                     182,                      /* interval year(..) to month */
                     183,                  /* interval day(..) to second(..) */
                     231)              /* timestamp(..) with local time zone */
                   and (c.type# != 23                     /* raw not raw oid */
                     or (c.type# = 23 and bitand(c.property, 2) = 2))
                 ) or
                 (c.segcol# = 0             /* virtual column: not supported */
                 ) or
                 (bitand(c.property, 2) = 2                    /* OID column */
                 ) or
                 (c.type# = 112 and c.charsetform = 2               /* NCLOB */
                 ) or
                 (c.type# = 112 and c.charsetform = 1 and
                  /* discussed with JIYANG, varying width CLOB */
                  c.charsetid >= 800
                 )
               )
             )
          )
         then 'unsupported column exists'
      when bitand(t.property, 1) = 1
        then 'object table'
      when bitand(t.property, 131072) = 131072
        then 'AQ queue table'
      /* x00400000 + 0x00800000 */
      when bitand(t.property, 4194304 + 8388608) != 0
        then 'temporary table'
      when bitand(t.property, 134217728) = 134217728          /* 0x08000000 */
        then 'sub object'
      when bitand(t.property, 2147483648) = 2147483648
        then 'external table'
      when bitand(t.property, 33554432 + 67108864) != 0
        then 'materialized view'
      when bitand(t.property, 32768) = 32768     /* 0x8000 has FILE columns */
        then 'FILE column exists'
      when
        (exists 
          (select 1 
           from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name
          )
        )
        then 'materialized view log'
      when bitand(t.flags, 262144) = 262144
        then 'materalized view container table'
      when bitand(t.trigflag, 268435456) = 268435456
        then 'streams unsupported object'
      when bitand(o.flags, 16) = 16
        then 'domain index'
      else null end) reason, 
      92,                                                      /* compatible */
      'NO'                                                  /* auto filtered */
  from sys.obj$ o, sys.user$ u, sys.tab$ t
  where t.obj# = o.obj#
    and o.owner# = u.user#
    and u.name not in ('SYS', 'SYSTEM', 'CTXSYS')
    and bitand(o.flags,
                  2                                      /* temporary object */
                + 4                               /* system generated object */
                + 32                                 /* in-memory temp table */
                + 128                          /* dropped table (RecycleBin) */
                  ) = 0
    and
      (  (bitand(t.property, 
                64                                                    /* IOT */
              + 128         /* 0x00000080              IOT with row overflow */
              + 256         /* 0x00000100            IOT with row clustering */
              + 512         /* 0x00000200               iot OVeRflow segment */
             ) != 0
          ) or
          (bitand(t.flags,
                268435456    /* 0x10000000   IOT with Phys Rowid/mapping tab */
              + 536870912    /* 0x20000000 Mapping Tab for Phys rowid of IOT */
             ) != 0
          ) or
          (bitand(t.property, 262208) = 262208  /* 0x40+0x40000 IOT+user LOB */
          ) or
          (bitand(t.property, 2112) = 2112  /* 0x40+0x800 IOT + internal LOB */
          ) or
          (bitand(t.property, 64) != 0 and                           /* 0x40 */
             bitand(t.flags, 131072) != 0                         /* 0x20000 */
          ) or                                    /* IOT with "Row Movement" */
          (bitand(t.property,
                  1                                           /* typed table */
                + 2                                           /* ADT columns */
                + 4                                  /* nested table columns */
                + 8                                           /* REF columns */
                + 16                                        /* array columns */
                + 4096                                             /* pk OID */
                + 8192              /* storage table for nested table column */
                + 65536                                              /* sOID */
               ) != 0
          ) or
          (exists                                      /* unsupported column */
            (select 1 from sys.col$ c 
             where t.obj# = c.obj#
               and
               ( (bitand(c.property, 32) = 32                      /* hidden */
                 ) or
                 (c.type# not in ( 
                     1,                                          /* varchar2 */
                     2,                                            /* number */
                     12,                                             /* date */
                     96,                                             /* char */
                     112,                                  /* clob and nclob */
                     113,                                            /* blob */
                     180,                                  /* timestamp (..) */
                     181,                    /* timestamp(..) with time zone */
                     182,                      /* interval year(..) to month */
                     183,                  /* interval day(..) to second(..) */
                     231)              /* timestamp(..) with local time zone */
                   and (c.type# != 23                     /* raw not raw oid */
                     or (c.type# = 23 and bitand(c.property, 2) = 2))
                 ) or
                 (c.segcol# = 0             /* virtual column: not supported */
                 ) or
                 (bitand(c.property, 2) = 2                    /* OID column */
                 ) or
                 (c.type# = 112 and c.charsetform = 2               /* NCLOB */
                 ) or
                 (c.type# = 112 and c.charsetform = 1 and
                  /* discussed with JIYANG, varying width CLOB */
                  c.charsetid >= 800
                 )
               )
             )
          ) or
          (bitand(t.property, 1) = 1                         /* object table */
          ) or 
          (bitand(t.property,
                131072      /* 0x00020000 table is used as an AQ queue table */
              + 4194304     /* 0x00400000             global temporary table */
              + 8388608     /* 0x00800000   session-specific temporary table */
              + 33554432    /* 0x02000000        Read Only Materialized View */
              + 67108864    /* 0x04000000            Materialized View table */
              + 134217728   /* 0x08000000                    Is a Sub object */
              + 2147483648   /* 0x80000000                    eXternal TaBle */
             ) != 0
          ) or
          (bitand(t.flags,
                  262144              /* 0x00040000   MV Container Table, MV */
                 ) = 262144
          ) or 
          (bitand(t.property, 32768) = 32768      /* 0x8000 has FILE columns */
          ) or 
          (bitand(t.trigflag, 268435456) = 268435456/* 0x10000000 strm unsup */
          ) or 
          (exists 
            (select 1 
             from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name
            )
          )
        )
/

select * from PHM_STREAMS_UNSUPPORTED_9_2;

prompt ++   STREAMS DICTIONARY INFORMATION ++
prompt    Capture processes defined on system
prompt

col queue format a30 wrap heading 'Queue|Name'
col capture_name format a20 wrap heading 'Capture|Name'
col capture# format 9999 heading 'Capture|Number'
col ruleset format a30 wrap heading 'Rule Set'


select queue_owner||'.'||queue_name queue,capture_name,capture#,ruleset_owner||'.'||ruleset_name ruleset from sys.streams$_capture_process;

prompt    Apply processes defined on system
prompt
col apply_name format a20 wrap heading 'Apply|Name'
col apply# format 9999 heading 'Apply|Number'

select queue_owner||'.'||queue_name queue,apply_name,apply#,ruleset_owner||'.'||ruleset_name  ruleset from sys.streams$_apply_process;

prompt    Propagations defined on system
prompt
col source_queue format a30 wrap heading 'Queue|Name'
col destination format a40 wrap heading 'Destination'

select source_queue_schema||'.'||source_queue source_queue, 
   destination_queue_schema||'.'||destination_queue||'@'||
   destination_dblink destination,
   ruleset_schema||'.'||ruleset ruleset from sys.STREAMS$_PROPAGATION_PROCESS;

prompt    Streams rules defined on system
prompt
col nbr format 999999 heading 'Number of|Rules'

select streams_name,streams_type,count(*) nbr From sys.streams$_rules group by streams_name,streams_type;

prompt ++ 
prompt ++ LOGMINER DATABASE MAP ++
prompt    Databases with information in logminer tables
prompt
col global_name format a30 wrap heading 'Global|Name'
col logmnr_uid format 99999999  heading 'Logminer|Identifier';

select * from system.logmnrc_dbname_uid_map;

prompt ++ LOGMINER CACHE OBJECTS ++
prompt     Objects of interest to Streams from each source database
prompt
col count(*) format 99999999  heading 'Number of|Interesting|DB Objects';

select logmnr_uid, count(*) from system.logmnrc_gtlo group by logmnr_uid;

prompt     Intcol Verification
prompt  

select logmnr_uid, obj#, objv#, intcol#
      from system.logmnrc_gtcs
      group by logmnr_uid, obj#, objv#, intcol#
      having count(1) > 1
      order by 1,2,3,4;

prompt
Prompt   ++ JOBS in Database ++
prompt
set recsep each
set recsepchar =
select * from dba_jobs;

set recsep off

prompt ++ Agents ++
prompt
select * from dba_aq_agents;
prompt

prompt ++ Agent Privileges ++
prompt
select * from dba_aq_agent_privs;

prompt
prompt  ++  Current Long Running Transactions ++  
prompt   Current transactions open for more than 20 minutes
prompt
col runlength HEAD 'Txn Open|Minutes' format 9999.99
col sid HEAD 'Session' format a13
col xid HEAD 'Transaction|ID' format a18
col terminal HEAD 'Terminal' format a10
col program HEAD 'Program' format a27 wrap

select sid||','||serial# sid,xidusn||'.'||xidslot||'.'||xidsqn xid, 
(sysdate -  to_date(start_time,'MM/DD/YY HH24:Mi:SS') ) * 1440 runlength ,terminal,program from v$transaction t, v$session s 
where t.addr=s.taddr and (sysdate - to_date(start_time,'MM/DD/YY HH24:Mi:SS') ) * 1440 > 20;

drop table phm_streams_rules;

prompt   ++ init.ora parameters ++
Prompt  Key parameters are aq_tm_processes, job_queue_processes
prompt                     shared_pool_size, sga_max_size, global_name, compatible
prompt                     log_parallelism, logmnr_max_persistent_sessions


show parameters

