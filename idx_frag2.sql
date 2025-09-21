-- SELECT only those indexes with an estimated space saving percent greater than 25%
VAR savings_percent NUMBER;
EXEC :savings_percent:=25;
-- SELECT only indexes with current size (as per cbo stats) greater then 1MB
VAR minimum_size_mb NUMBER;
EXEC :minimum_size_mb:=1;
set feed on verify off termout on define "&" trims on trim on head on
SET SERVEROUT ON ECHO OFF FEED OFF VER OFF TAB OFF LINES 300
col report_date NEW_V report_date
SELECT
    to_char(sysdate,'YYYY-MM-DD"T"HH24:MI:SS')report_date
FROM
    dual;
spool /tmp/indexes_2b_shrunk_&&report_date..txt;
DECLARE
    l_used_bytes  NUMBER;
    l_alloc_bytes NUMBER;
    l_percent     NUMBER;
BEGIN
--    dbms_output.put_line('PDB: '||sys_context('USERENV','CON_NAME'));
    dbms_output.put_line('---');
    dbms_output.put_line(rpad('INDEX_NAME',45)||' '||rpad('TABLE_NAME',35)||' '||lpad('SAVING %',10)||' '||lpad('CURRENT SIZE',20)||' '||lpad('ESTIMATED SIZE',20));
    dbms_output.put_line(rpad('-',45,'-')||' '||lpad('-',10,'-')||' '||lpad('-',20,'-')||' '||lpad('-',20,'-'));
    FOR i IN(
        SELECT
            x.owner
           ,x.table_name
           ,x.index_name
           ,sum(s.leaf_blocks)*to_number(p.value)                                        index_size
           ,replace(dbms_metadata.get_ddl('INDEX',x.index_name,x.owner),chr(10),chr(32)) ddl
        FROM
            dba_ind_statistics s
           ,dba_indexes        x
           ,dba_users          u
           ,gv$parameter        p
        WHERE
            x.owner=u.username
            AND x.tablespace_name NOT IN('SYSTEM','SYSAUX')
            AND x.index_type LIKE '%NORMAL%'
            AND x.table_type='TABLE'
            AND x.status='VALID'
            AND x.temporary='N'
            AND x.dropped='NO'
            AND x.visibility='VISIBLE'
            AND x.segment_created='YES'
--          AND x.orphaned_entries='NO'
--          AND u.oracle_maintained='N'
            AND p.name='db_block_size'
            AND s.owner=x.owner
            AND s.index_name=x.index_name
            AND u.username NOT IN ('SYS','SYSTEM','DMSYS','EXFSYS','MGMT_VIEW','SYSMAN','TSMSYS','APEX_030200','APEX_PUBLIC_USER','FLOWS_FILES','OWBSYS','OWBSYS_AUDIT','SPATIAL_WFS_ADMIN_USR','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DIP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','GSMCATUSER','GSMUSER','GSMROOTUSER','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','REMOTE_SCHEDULER_AGENT','SI_INFORMTN_SCHEMA','SYS$UMF','SYSBACKUP','SYSDG','SYSKM','SYSRAC','WMSYS','XDB','XS$NULL','SPATIAL_CSW_ADMIN_USR')
        GROUP BY
            x.owner
           ,x.table_name
           ,x.index_name
           ,p.value
        HAVING
            sum(s.leaf_blocks)*to_number(p.value)> :minimum_size_mb*power(2,20)
        ORDER BY
            index_size DESC
    )LOOP
        dbms_space.create_index_cost(i.ddl,l_used_bytes,l_alloc_bytes);
        IF i.index_size*(100- :savings_percent)/100>l_alloc_bytes THEN
            l_percent:=100*(i.index_size-l_alloc_bytes)/i.index_size;
            dbms_output.put_line(rpad(i.owner||'.'||i.index_name,45)||' '||rpad(i.table_name,35)||' '||lpad(to_char(round(l_percent,1),'990.0')||' % ',10)||' '||lpad(to_char(round(i.index_size/power(2,20),1),'999,999,990.0')||' MB',20)||' '||lpad(to_char(round(l_alloc_bytes/power(2,20),1),'999,999,990.0')||' MB',20));
        END IF;
    END LOOP;
END;
/
spool off
