--
--  Script    : set_trace.sql
--  Purpose   : create a procedure for tracing a session 
--  Tested on : 8i,9i,10g,11g,12c,19c
--
CREATE OR REPLACE PROCEDURE set_trace AS
  v_sid     v_$session.sid%type;
  v_serial# v_$session.serial#%type;
BEGIN
  v_sid:=NULL;
  v_serial#:=NULL;
  LOOP
    BEGIN
      SELECT sid,serial# INTO v_sid,v_serial# FROM v_$session WHERE username='GTADM';
    EXCEPTION
      WHEN no_data_found THEN NULL;
      WHEN OTHERS THEN dbms_output.put_line(sqlerrm);
    END;
    IF sql%rowcount>=1 THEN
      dbms_system.set_ev(v_sid,v_serial#,10046,12,'');
      exit;
    END IF;
  END LOOP;
END;
/