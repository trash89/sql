col date_jour new_value jour
select to_char(sysdate,'DDMMYYYY') date_jour from dual;
spool /tmp/DBSPI_V10.log
col HOST_NAME format a20
col version format a11
set lines 150
col deb format a26
col "Effectue le" format a26
select HOST_NAME,version,INSTANCE_NAME,to_char(STARTUP_TIME,'YYYY/MM/DD HH24:MI:SS') deb , to_char(sysdate,'YYYY/MM/DD HH24:MI:SS') "Effectue le" , status , logins  from v$instance;
set echo on termout on
grant select on SYS.DEFTRAN to HP_DBSPI;
grant select on SYS.DEFERROR to HP_DBSPI;
grant select on SYS.V_$RECOVERY_FILE_DEST to HP_DBSPI;
grant select on SYS.DEFTRAN to HP_DBSPI;
grant select on SYS.DEFERROR to HP_DBSPI;
grant select on SYS.DBA_REPCATLOG to HP_DBSPI;
spool off
exit SQL.SQLCODE
