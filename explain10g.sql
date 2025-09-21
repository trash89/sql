rem
rem     Script:         explain10g.sql
rem     Author:         Jonathan Lewis
rem     Purpose:        q and d to execute explain plan (Oracle 9i)
rem     Modification:   Marius RAICU
rem                     Adding the Distribution column(disponible in 8i and 9i)
rem          CPU_COST,IO_COST,TEMP_SPACE(disponibles only in 9i)
rem                     Tested on 9.0.1.3
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
rem             Start explain9i.sql
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

@save_sqp_set

set pagesize 24 linesize 500 
col plan                for a400        head "Plan"
col id                  for 999         head "Id"
col parent_id           for 999         head "Par"
col position            for 999         head "Pos"
col object_instance     for 999         head "Ins"
col state_id new_value m_statement_id
SELECT
        userenv('sessionid') state_id
FROM
        dual;
EXPLAIN PLAN
SET STATEMENT_ID='&m_statement_id'
FOR
@target
SET FEEDBACK OFF
SPOOL &m_statement_id
SELECT
        ID,
        PARENT_ID,
        POSITION,
        OBJECT_INSTANCE,
        RPAD(' ',2*LEVEL)||
        OPERATION||' '||
        DECODE(OPTIMIZER,NULL,NULL,
                '('||LOWER(OPTIMIZER)||') '
        )||
        OBJECT_TYPE||' '||
        OBJECT_OWNER||' '||
        OBJECT_NAME||' '||
        DECODE(OPTIONS,NULL,NULL,'('||LOWER(OPTIONS)||') ')||
        DECODE(SEARCH_COLUMNS,NULL,NULL,
                '(Columns '||SEARCH_COLUMNS||' '
        )||
        OTHER_TAG||' '||
        DECODE(PARTITION_ID,NULL,NULL,
                'Pt id: '||PARTITION_ID||' '
        )||
        DECODE(PARTITION_START,NULL,NULL,
                'Pt Range: '||PARTITION_START||' - '||
                PARTITION_STOP||' '
        )||
        DECODE(COST,NULL,NULL,
                'Cost ('||COST||','||CARDINALITY||','||BYTES||')')||
        DECODE(CPU_COST,NULL,NULL,' CPU='||CPU_COST)||
        DECODE(IO_COST,NULL,NULL,' IO='||IO_COST)||
        DECODE(TEMP_SPACE,NULL,NULL,' TempS='||TEMP_SPACE)||
        DECODE(TIME,NULL,NULL,' Time='||TIME)||
        DECODE(ACCESS_PREDICATES,NULL,NULL,' Pred='||ACCESS_PREDICATES)||
        DECODE(FILTER_PREDICATES,NULL,NULL,' Filt='||FILTER_PREDICATES)
                PLAN
FROM
        PLAN_TABLE
CONNECT BY
        PRIOR ID=PARENT_ID AND STATEMENT_ID='&m_statement_id'
START WITH
        ID=0 AND STATEMENT_ID='&m_statement_id'
ORDER BY
        ID
;

rem     *************************************
rem
rem     Dump remote code, PQ slave code etc.
rem     but only for lines which have some
rem
rem     *************************************

set long 20000
SELECT
        id
       ,object_node
       ,other
       ,distribution
FROM
        plan_table
WHERE
        statement_id='&m_statement_id'
        AND(other IS NOT NULL)
        OR(distribution IS NOT NULL)
ORDER BY
        id
;
ROLLBACK;
EXPLAIN PLAN
SET STATEMENT_ID='&m_statement_id'
FOR
@target

SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY(NULL,'&m_statement_id','TYPICAL allstats'));
ROLLBACK;
spool off

@rest_sqp_set
