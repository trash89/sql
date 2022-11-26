select distinct owner,table_name from dba_tab_columns where data_type in ('VARCHAR2','CHAR') and char_used='B' and owner not in ('SYS','SYSTEM','OUTLN','DBSNMP','CTXSYS','DRSYS','MDSYS','ORDSYS','ORDPLUGINS','TRACESVR',
          'AURORA$JIS$UTILITY$','AURORA$ORB$UNAUTHENTICATED','LBACSYS','OLAPDBA','OLAPSVR','OLAPSYS','OSE$HTTP$ADMIN',
          'WKSYS','XDB','WMSYS','WK_TEST','WK_PROXY','SYSMAN','SI_INFORMTN_SCHEMA','SCOTT','MGMT_VIEW','MDDATA',
          'FLOWS_FILES','FLOWS_010600','FLOWS_020000','EXFSYS','DMSYS','ANONYMOUS','BC4J','WFADMIN','OWBRT10GR1_TARGET',
          'OWBRT10GR1_REF','OWBRT10GR1_USR','OWBRT_SYS','OWF_MGR','HTML_PUBLIC_USER') and table_name not in (select view_name from dba_views)
/

set serveroutput on size unlimited
declare
  str varchar2(32000):=null;
begin
  for rec in (select username from all_users where username not in 
          ('SYS','SYSTEM','OUTLN','DBSNMP','CTXSYS','DRSYS','MDSYS','ORDSYS','ORDPLUGINS','TRACESVR',
          'AURORA$JIS$UTILITY$','AURORA$ORB$UNAUTHENTICATED','LBACSYS','OLAPDBA','OLAPSVR','OLAPSYS','OSE$HTTP$ADMIN',
          'WKSYS','XDB','WMSYS','WK_TEST','WK_PROXY','SYSMAN','SI_INFORMTN_SCHEMA','SCOTT','MGMT_VIEW','MDDATA',
          'FLOWS_FILES','FLOWS_010600','FLOWS_020000','EXFSYS','DMSYS','ANONYMOUS','BC4J','WFADMIN','OWBRT10GR1_TARGET',
          'OWBRT10GR1_REF','OWBRT10GR1_USR','OWBRT_SYS','OWF_MGR','HTML_PUBLIC_USER')
    ) loop
        for rec2 in (select distinct owner,table_name from dba_tab_columns where data_type in ('VARCHAR2','CHAR') and char_used='B' and owner=rec.username and table_name not in (select view_name from dba_views)) loop
          begin
            str:='alter table '||rec2.owner||'.'||rec2.table_name||' disable all triggers';
            execute immediate str;
            for rec3 in (select owner,table_name,column_name,data_type,char_length from dba_tab_columns where data_type in ('VARCHAR2','CHAR') and char_used='B' and owner=rec2.owner and table_name not in (select view_name from dba_views)) loop
              str:='alter table '||rec3.owner||'.'||rec3.table_name||' modify '||rec3.column_name||' '||rec3.data_type||'('||rec3.char_length||' char'||')';
              begin
                execute immediate str;
              exception 
                when others then dbms_output.put_line(sqlerrm||'  '||str);
              end;
            end loop;
            str:='alter table '||rec2.owner||'.'||rec2.table_name||' enable all triggers';
            execute immediate str;
          exception
          when others then dbms_output.put_line(sqlerrm||'  '||str);
          end;
        end loop;
  end loop;
  for rec in (select username from all_users where username not in 
          ('SYS','SYSTEM','OUTLN','DBSNMP','CTXSYS','DRSYS','MDSYS','ORDSYS','ORDPLUGINS','TRACESVR',
          'AURORA$JIS$UTILITY$','AURORA$ORB$UNAUTHENTICATED','LBACSYS','OLAPDBA','OLAPSVR','OLAPSYS','OSE$HTTP$ADMIN',
          'WKSYS','XDB','WMSYS','WK_TEST','WK_PROXY','SYSMAN','SI_INFORMTN_SCHEMA','SCOTT','MGMT_VIEW','MDDATA',
          'FLOWS_FILES','FLOWS_010600','FLOWS_020000','EXFSYS','DMSYS','ANONYMOUS','BC4J','WFADMIN','OWBRT10GR1_TARGET',
          'OWBRT10GR1_REF','OWBRT10GR1_USR','OWBRT_SYS','OWF_MGR','HTML_PUBLIC_USER')
    ) loop
    for rec2 in (select owner,view_name from dba_views where owner=rec.username) loop
        begin
          str:='alter view '||rec2.owner||'.'||rec2.view_name||' compile';
          execute immediate str;
        exception
        when others then
          dbms_output.put_line(sqlerrm||'  '||str);
        end;
    end loop;
  end loop;
end;
/


@?/rdbms/admin/utlrp.sql
