set lines 150 pages 66
column owner format a10
column table_name format a30 heading 'Table|Name'
column tablespace_name format a15 heading 'Tablespace|Name'
column pct_free format 99 heading 'Pct|Free'
column pct_used format 99 heading 'Pct|Used'
column ini_trans format 99999 heading 'Ini|Trans'
column max_trans format 99999 heading 'Max|Trans'
column ini_ext format 99999.99 heading 'Ini|Ext(M)'
column next_ext format 99999.99 heading 'Next|Ext(M)'
column min_extents format 9999 heading 'Min|Exts'
column max_extents format 9999999999 heading 'Max|Exts'
column pct_increase format 999 heading 'Pct|Inc%'
select owner,
       table_name,
       tablespace_name,
       pct_free,
       pct_used,
       ini_trans,
       max_trans,
       initial_extent/1024/1024 as ini_ext,
       next_extent/1024/1024 as next_ext,
       min_extents,
       max_extents,
       pct_increase, 
       cache,
       buffer_pool
from dba_tables 
where owner not in (
'ANONYMOUS',
'APPQOSSYS',
'AUDSYS',
'CTXSYS',
'DBSFWUSER',
'DBSNMP',
'DIP',
'DVF',
'DVSYS',
'GGSYS',
'GSMADMIN_INTERNAL',
'GSMCATUSER',
'GSMROOTUSER',
'GSMUSER',
'LBACSYS',
'MDDATA',
'MDSYS',
'OJVMSYS',
'OLAPSYS',
'ORACLE_OCM',
'ORDDATA',
'ORDPLUGINS',
'ORDSYS',
'OUTLN',
'REMOTE_SCHEDULER_AGENT',
'RQSYS',
'SI_INFORMTN_SCHEMA',
'SYS',
'SYS$UMF',
'SYSBACKUP',
'SYSDG',
'SYSKM',
'SYSRAC',
'SYSTEM',
'WMSYS',
'XDB',
'XS$NULL',
'CTXAPP',
'AQ_ADMINISTRATOR_ROLE',
'AURORA$JIS$UTILITY$',
'AURORA$ORB$UNAUTHENTICATED',
'BC4J',
'CTXSYS',
'JAVADEBUGPRIV',
'JAVASYSPRIV',
'OEM_MONITOR',
'OLAPDBA',
'OLAPSVR',
'OLAP_DBA',
'OSE$HTTP$ADMIN',
'TIMESERIES_DBA',
'TIMESERIES_DEVELOPER',
'TRACESVR',
'WKSYS',
'WKUSER',
'WKADMIN',
'PTRLADM'
) 
order by owner,tablespace_name,table_name;
clear columns
set lines 150 pages 22

