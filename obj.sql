set lines 200 pages 22 trims off trim on
undef own
accept own char prompt 'Owner?(%)      :' default '%'
col obj format a39 head 'Object Name'
col object_type for a22 head 'Object Type'
col object_id for 9999999 head 'Obj ID'
col temporary for a4 head 'Temp'
col generated for a3 head 'Gen'
col secondary for a3 head 'Sec'
select 
   owner||'.'||object_name as obj,
   object_type,
   created,
   last_ddl_time,
   status,
   object_id,
   temporary,
   generated,
   secondary 
from dba_objects
where 
     owner like upper('%&&own%') and owner not in (
                   'SYS',
                   'SYSTEM',
                   'RECOVERY_CATALOG_OWNER',
		   'EXECUTE_CATALOG_ROLE',
		   'SELECT_CATALOG_ROLE',
                   'DBA',
                   'RESOURCE',
                   'CONNECT',
                   'SNMPAGENT',
                   'IMP_FULL_DATABASE',
                   'EXP_FULL_DATABASE',
                   'PERFSTAT',
                   'OUTLN',
                   'DBSNMP',
		   'AQ_USER_ROLE',
		   'HS_ADMIN_ROLE',
		   'WM_ADMIN_ROLE',
		   'CTXAPP',
		   'LBAC_DBA',
                   'AQ_ADMINISTRATOR_ROLE',
		   'AURORA$JIS$UTILITY$',
		   'AURORA$ORB$UNAUTHENTICATED',
		   'BC4J',
		   'CTXSYS',
		   'JAVADEBUGPRIV',
		   'JAVASYSPRIV',
		   'LBACSYS',
		   'MDSYS',
		   'OEM_MONITOR',
		   'OLAPDBA',
		   'OLAPSVR',
		   'OLAPSYS',
		   'OLAP_DBA',
		   'ORDPLUGINS',
		   'ORDSYS',
		   'OSE$HTTP$ADMIN',
		   'RECOVERY_CATALOG_OWNER',
		   'TIMESERIES_DBA',
		   'TIMESERIES_DEVELOPER',
		   'TRACESVR',
		   'WKSYS',
		   'WKUSER',
		   'WKADMIN',
                   'PTRLADM',
		   'PUBLIC')
order by 
  owner,
  object_type,
  object_name;
undef own
clear col
set lines 80 pages 22 feed on head on
