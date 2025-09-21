--
--  Script    : show_prof.sql
--  Purpose   : show SQL Profiles FROM dba_sql_profiles
--  Tested on : 10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 4096 long 5000000 pages 50
col name            for a40
col category        for a25
col createdc        for a17 head 'Created'
col last_modifiedc  for a17 head 'Last Modified'
col type            for a7
col status          for a8
col sql_text        for a2048
ttitle left 'dba_sql_profiles'
SELECT
    name
   ,category
   ,to_char(created,'dd/mm/yyyy hh24:mi') AS createdc
   ,to_char(last_modified,'dd/mm/yyyy hh24:mi') AS last_modifiedc   
   ,type
   ,status
   ,sql_text
FROM
    dba_sql_profiles
ORDER BY
    last_modified
   ,name
;

@rest_sqp_set

-- drop a profile
-- exec DBMS_SQLTUNE.DROP_SQL_PROFILE ('my_sql_profile');

----- Saving profiles
-- exec DBMS_SQLTUNE.CREATE_STGTAB_SQLPROF (table_name  => 'my_staging_table',   schema_name => 'SYSTEM' );
-- SELECT count(*) FROM system.my_staging_table;
--
-- set feedback off verify off termout on lines 200 pages 0 head off
-- spool /tmp/save_profiles.sql
-- SELECT 'exec DBMS_SQLTUNE.PACK_STGTAB_SQLPROF (profile_name=> '||chr(39)||name||chr(39)||',   staging_table_name   => '||chr(39)||'my_staging_table'||chr(39)||',   staging_schema_owner => '||chr(39)||'SYSTEM'||chr(39)||' );' as col
-- FROM dba_sql_profiles;
-- spool off
-- ed /tmp/save_profiles.sql
-- SELECT count(*) FROM system.my_staging_table;

----- restoring profiles FROM my_staging_table
-- exec DBMS_SQLTUNE.UNPACK_STGTAB_SQLPROF(replace=> true,staging_table_name => 'my_staging_table',staging_schema_owner=>'SYSTEM');

----- dropping all profiles
-- set feedback off verify off termout on lines 200 pages 0 head off
-- spool /tmp/drop_profiles.sql
-- SELECT 'exec DBMS_SQLTUNE.DROP_SQL_PROFILE ('||chr(39)||name||chr(39)||');' as col
-- FROM dba_sql_profiles;
-- spool off
-- ed /tmp/drop_profiles.sql