@save_sqp_set

set lines 190 pages 50 trimout on 
col ROWLEN    for 999,999
col QLTY      for 999,990
col name for a90 head 'Index Name'
SELECT
       *
FROM
       (
              SELECT
                     'alter index '||i.owner||'.'||i.index_name||' rebuild online parallel 4;'                                  AS name
                    ,i.num_rows                                                                                                 num_rows
                    ,sum(tc.avg_col_len+1)+7 AS rowlen
                    ,i.leaf_blocks                                                                                              AS leaves
                    ,round((sum(tc.avg_col_len+1)+7)*i.num_rows/1000000,0)                                                      AS net_mb
                    ,round(i.leaf_blocks*(8079-23*i.ini_trans)*(1-i.pct_free/100)/1000000,0)                                    AS gross_mb
                    ,round((sum(tc.avg_col_len+1)+7)*i.num_rows/(i.leaf_blocks*(8079-23*i.ini_trans)*(1-i.pct_free/100))*100,0)as qlty
              FROM
                     dba_tables      t
                    ,dba_indexes     i
                    ,dba_tab_columns tc
                    ,dba_ind_columns ic
              WHERE
                     t.table_name=tc.table_name
                     AND t.owner=tc.owner
                     AND i.index_name=ic.index_name
                     AND i.owner=ic.index_owner
                     AND tc.table_name=ic.table_name
                     AND tc.owner=ic.index_owner
                     AND tc.column_name=ic.column_name
                     AND i.index_type='NORMAL'
                     AND i.owner LIKE '%'
                     AND i.owner NOT IN ('SYS','SYSTEM','DMSYS','EXFSYS','MGMT_VIEW','SYSMAN','TSMSYS','APEX_030200','APEX_PUBLIC_USER','FLOWS_FILES','OWBSYS','OWBSYS_AUDIT','SPATIAL_WFS_ADMIN_USR','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DIP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','GSMCATUSER','GSMUSER','GSMROOTUSER','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','REMOTE_SCHEDULER_AGENT','SI_INFORMTN_SCHEMA','SYS$UMF','SYSBACKUP','SYSDG','SYSKM','SYSRAC','WMSYS','XDB','XS$NULL','SPATIAL_CSW_ADMIN_USR')
                     AND i.leaf_blocks>200
              GROUP BY
                     i.owner
                    ,t.table_name
                    ,t.owner
                    ,i.num_rows
                    ,i.leaf_blocks
                    ,i.index_name
                    ,i.ini_trans
                    ,i.pct_free
              ORDER BY
                     7
       )
WHERE
       qlty<60
       AND ROWNUM<=50
;

@rest_sqp_set
