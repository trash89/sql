rem
rem     Script:         explain8.sql
rem     Author:         Jonathan Lewis
rem     Purpose:        q and d to execute explain plan (Oracle 8.0)
rem
rem     Preparation:
rem             Run $ORACLE_HOME/rdbms/admin/utlxplan.sql as SYSTEM
rem             Create public synonym plan_table for plan_table
rem             Grant all on plan_table to public
rem             Create an index (id,parent_id) on plan_table
rem
rem     Use:
rem             Put the guilty SQL statement (with ';') into a file called
rem                     target.sql
rem             Start explain8.sql
rem
rem             The script displays the current audit id, then
rem             the execution path, simultaneously writing the
rem             execution path to a file identified by the audit id.
rem
rem     Suggestions:
rem             Adjust termout on/off to taste
rem             Adjust pagesize to taste
rem             Adjust linesize to taste
rem             set pause on/off to taste
rem     

set pagesize 24
set linesize 180
set trimspool on
set verify off

set def =
set def &

column plan             format a160     heading "Plan"

column id               format 999      heading "Id"
column parent_id        format 999      heading "Par"
column position         format 999      heading "Pos"
column object_instance  format 999      heading "Ins"

column state_id new_value m_statement_id

select userenv('sessionid') state_id from dual;

explain plan
set statement_id = '&m_statement_id'
for
@target

set feedback off
spool &m_statement_id

select
        id,
        parent_id,
        position,
        object_instance,
        rpad(' ',2*level) ||
        operation || ' ' ||
        decode(optimizer,null,null,
                '(' || lower(optimizer) || ') '
        )  ||
        object_type || ' ' ||
        object_owner || ' ' ||
        object_name || ' ' ||
        decode(options,null,null,'('||lower(options)||') ') ||
        decode(search_columns, null,null,
                '(Columns ' || search_columns || ' '
        )  ||
        other_tag || ' ' ||
        decode(partition_id,null,null,
                'Pt id: ' || partition_id || ' '
        )  ||
        decode(partition_start,null,null,
                'Pt Range: ' || partition_start || ' - ' ||
                partition_stop || ' '
        ) ||
        decode(cost,null,null,
                --'Cost (' || cost || ',' || cardinality || ',' || bytes || ')'
                'Cost (' || cost || ',' || cardinality || ',' || ')'
        )
                plan
from
        plan_table
connect by
        prior id = parent_id and statement_id = '&m_statement_id'
start with
        id = 0 and statement_id = '&m_statement_id'
order by
        id
;

rem     *************************************
rem
rem     Dump remote code, PQ slave code etc.
rem     but only for lines which have some
rem
rem     *************************************

set long 20000

select
        id, object_node, other
from
        plan_table
where
        statement_id = '&m_statement_id'
and     other is not null
order by
        id;


rollback;

spool off
set feedback on

