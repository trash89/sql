--
--  File Name    : hb.sql
--  Author       : Tim Hall
--  Description  : Detects hot blocks.
--  Last Modified: 12/2024 - Marius RAICU - add owner.object_name
--  Tested on : 10g,11g,12c,19c
--
@save_sqp_set

set lines 150 pages 50
ttitle left 'v$latch_children'
SELECT *
FROM   (SELECT name,
               addr,
               gets,
               misses,
               sleeps
        FROM   
                gv$latch_children
        WHERE  
                name = 'cache buffers chains'
                AND misses > 0
                AND inst_id=to_number(sys_context('USERENV','INSTANCE'))
        ORDER BY misses DESC
        )
WHERE  
        rownum < 11
;

ACCEPT address PROMPT "Enter ADDR: "

col objn for a60
col subobject_name for a20
ttitle left 'sys.x$bh'
SELECT *
FROM   (SELECT o.owner||'.'||o.object_name as objn,
               o.subobject_name,
               bh.tch,
               bh.obj,
               bh.file#,
               bh.dbablk,
               bh.class,
               bh.state
        FROM   
                sys.x$bh bh,
                dba_objects o
        WHERE  
                o.data_object_id = bh.obj
                AND hladdr = '&address'
                AND inst_id=to_number(sys_context('USERENV','INSTANCE'))
        ORDER BY tch DESC
        )
WHERE  
        rownum < 11
;

@rest_sqp_set

-- when ERROR at line 1: ORA-00054: resource busy and acquire with NOWAIT specified or timeout expired, DDL_LOCK_TIMEOUT in seconds
--alter session set DDL_LOCK_TIMEOUT = 60;
--declare
--should_exit boolean:=false;
--begin
--  loop
--     begin
--     execute immediate 'alter index encaiss.INPI_PAIEMENT_IDX_003 initrans 10';
--     should_exit:=true;
--     exception
--        when others then  null;
--     end;
--     exit when should_exit=true;
--  end loop;
--end;
--/


