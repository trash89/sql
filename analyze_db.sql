set serveroutput on size 10000
grant analyze any to sys;
create or replace
procedure sys.analyze_db is
begin
	for rec in (select username from all_users where username not in ('SYS','SYSTEM','OUTLN','DBSNMP','CTXSYS','DRSYS','MDSYS','ORDSYS','ORDPLUGINS','TRACESVR','AURORA$JIS$UTILITY$','AURORA$ORB$UNAUTHENTICATED','LBACSYS','OLAPDBA','OLAPSVR','OLAPSYS','OSE$HTTP$ADMIN','WKSYS','XDB','WMSYS','WK_TEST','WK_PROXY','SYSMAN','SI_INFORMTN_SCHEMA','SCOTT','MGMT_VIEW','MDDATA','EXFSYS','DMSYS','ANONYMOUS','BC4J')) loop
		begin
			sys.dbms_stats.gather_schema_stats(
				ownname=>rec.username,
				estimate_percent=>null, 
				block_sample=>FALSE,
				method_opt=>'FOR ALL COLUMNS SIZE AUTO',
				degree=>NULL,
				granularity=>'ALL', 
				cascade=>true,
				options=>'GATHER AUTO'
				);
		exception
			when others then raise;
		end;
	end loop;
end;
/
show errors

declare
  j number;
begin
  for rec in (select job from dba_jobs where what like '%analyze_db%') loop
    dbms_job.remove(rec.job);
    commit;
  end loop;
  dbms_job.submit(j,'analyze_db;',trunc(sysdate)+1+1/24,'trunc(sysdate)+1+2/24');
  commit;
end;
/


