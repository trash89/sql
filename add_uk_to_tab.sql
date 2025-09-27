--
--  Script    : add_uk_to_tab.sql
--  Purpose   : add unique index to a table
--            : See : How to Handle Tables Without Primary Keys or Unique Indexes With Oracle GoldenGate (Doc ID 1271578.1)
--  Tested on : 12c,19c
--
@save_sqp_set

set lines 150 pages 50

undef tab
undef own
accept own char prompt 'Owner?(%)      : ' default ''
accept tab char prompt 'Table?(%)      : ' default ''

alter session set DDL_LOCK_TIMEOUT = 60;

prompt Adding OGG_KEY_ID raw(16) column ...
alter table "&&own"."&&tab" add OGG_KEY_ID raw(16);
alter table "&&own"."&&tab" modify OGG_KEY_ID default sys_guid(); 

prompt Generating triggers enable/disable statements ...
set head off autoprint off echo off show off tab off termout off newp none feed off lines 4096 long 5000000
spool /tmp/disable_triggers.sql
SELECT 
    'alter trigger '||owner||'.'||trigger_name||' disable;'
FROM
   dba_triggers
WHERE
   table_owner=upper('&&own')
   AND table_name=upper('&&tab')
   AND status='ENABLED'
;
spool off

spool /tmp/enable_triggers.sql
SELECT 
    'alter trigger '||owner||'.'||trigger_name||' enable;'
FROM
   dba_triggers
WHERE
   table_owner=upper('&&own')
   AND table_name=upper('&&tab')
   AND status='ENABLED'
;
spool off

set termout on
prompt Disabling triggers ...
@/tmp/disable_triggers.sql

prompt Updating OGG_KEY_ID ...
DECLARE 
    cursor C1 is select ROWID from "&&own"."&&tab" where OGG_KEY_ID is null;
    finished number:=0; 
    commit_cnt number:=0; 
    err_msg varchar2(150);
    snapshot_too_old exception; 
    pragma exception_init(snapshot_too_old, -1555);
    old_size number:=0; current_size number:=0;
BEGIN
    while (finished=0) loop
        finished:=1;
        BEGIN
            for C1REC in C1 LOOP
                update "&&own"."&&tab" set OGG_KEY_ID = sys_guid() where ROWID = C1REC.ROWID;
                commit_cnt:= commit_cnt + 1;
                IF (commit_cnt = 10000) then
                    commit;
                    commit_cnt:=0;
                END IF;
            END LOOP;
        EXCEPTION
            when snapshot_too_old then
                finished:=0;
            when others then
                rollback;
                err_msg:=substr(sqlerrm,1,150);
                raise_application_error(-20555, err_msg);
        END;
    END LOOP;
    IF(commit_cnt > 0) then
        commit;
    END IF;
END;
/
prompt Enabling triggers ...
@/tmp/enable_triggers.sql

alter table "&&own"."&&tab" modify (OGG_KEY_ID not null);

prompt Creating the index "&&own"."OGGUK_&&tab" ...
create unique index "&&own"."OGGUK_&&tab" on "&&own"."&&tab" (OGG_KEY_ID) logging online;

prompt 
prompt Note for GoldenGate:
prompt
prompt Create Table Supplemental Log Group in Source Database:
prompt
prompt GGSCI> dblogin userid <username>, password <password>
prompt GGSCI> add trandata "&&own"."&&tab", COLS (OGG_KEY_ID), nokey
prompt
prompt Specify OGG_KEY_ID for Table Key in Extract Parameter File:
prompt
prompt TABLE "&&own"."&&tab", KEYCOLS (OGG_KEY_ID);
prompt 

undef tab
undef own

@rest_sqp_set
