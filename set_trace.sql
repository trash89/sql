create or replace procedure set_trace as
  v_sid v_$session.sid%type;
  v_serial# v_$session.serial#%type;
begin
  v_sid:=null;
  v_serial#:=null;
  loop
    begin
      select sid,serial# into v_sid,v_serial# from v_$session where username='GTADM';
    exception
      when no_data_found then
         null;
      when others then
        dbms_output.put_line(sqlerrm); 
    end;
    if sql%rowcount>=1 then
      dbms_system.set_ev(v_sid,v_serial#,10046,12,'');
      exit;
    end if;    
  end loop;
end;
/
