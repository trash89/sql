set term off trim on trims on
column inst noprint new_value inst
select '/tmp/'||instance as inst from v$thread;
set term on
col anlcol format a200
set lines 180 pages 0 head off feed off trim on trims on term off verify off
spool &&inst..sql
select 'spool &&inst..log' from dual;
select 'analyze table '||owner||'.'||table_name||' delete statistics;'||chr(13)||chr(10)||'analyze table '||owner||'.'||table_name||' compute statistics for table for all indexes for all columns size 75;' as anlcol from dba_tables where owner not in 
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
select 'spool off' from dual;
spool off
set feed on term on echo on
@&&inst..sql
set feed off
select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') from dual;
