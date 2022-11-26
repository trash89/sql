set serveroutput on
declare
 a number;
begin
  commit;
  a:=dbms_defer_sys.purge(purge_method=>2);
end;
/
commit;
select count(*) from defcall;
