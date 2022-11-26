set lines 150 pages 0 head off
spool /tmp/enablerowmov.sql
select 'alter table '||owner||'.'||table_name||' enable row movement;' from dba_tables
where owner not in 
	('SYS',
	'SYSTEM',
	'OUTLN',
	'DBSNMP',
	'CTXSYS',
	'DRSYS',
	'MDSYS',
	'ORDSYS',
	'ORDPLUGINS',
	'TRACESVR',
	'AURORA$JIS$UTILITY$',
	'AURORA$ORB$UNAUTHENTICATED',
	'LBACSYS',
	'OLAPDBA',
	'OLAPSVR',
	'OLAPSYS',
	'OSE$HTTP$ADMIN',
	'WKSYS',
	'XDB',
	'WMSYS',
	'WK_TEST',
	'WK_PROXY',
	'SYSMAN',
	'SI_INFORMTN_SCHEMA',
	'SCOTT',
	'MGMT_VIEW',
	'MDDATA',
	'EXFSYS',
	'DMSYS',
	'ANONYMOUS',
	'BC4J');
spool off
set lines 150 pages 22 head on
@/tmp/enablerowmov.sql
host rm -f /tmp/enablerowmov.sql
