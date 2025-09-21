--
--  Script : audit.sql
--  Purpose: create the audit_SCHEMA trigger for setting the 10046 event, level 12
--  For    : 8i+
--

undef sch
accept sch char prompt 'Schema? : ' default ''
CREATE OR REPLACE TRIGGER AUDIT_&&SCH AFTER LOGON ON &&SCH..SCHEMA
DECLARE
  v_sid     gV$SESSION.SID%TYPE;
  v_serial# gV$SESSION.SERIAL#%TYPE;
BEGIN
  SELECT 
     S.SID
    ,S.SERIAL# 
  INTO 
     V_SID
    ,V_SERIAL# 
  FROM 
    gV$SESSION S
  WHERE EXISTS (
      SELECT NULL 
      FROM 
        gV$MYSTAT M 
      WHERE 
        M.SID=S.SID 
      )
  ;
  DBMS_SYSTEM.SET_EV(V_SID,V_SERIAL#,10046,12,'');
END;
/
prompt The trigger is :audit_&&sch