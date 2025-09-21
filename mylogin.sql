--
--  Script    : mylogin.sql
--  Purpose   : set the sql prompt with host_name,database name etc
--  Tested on : 8i+ 
--
set term off
variable ins varchar2(80 char)
BEGIN
    SELECT i.host_name||':'||global_name||':'||unq_name||':'||user INTO :ins
    FROM
        gv$thread t
       ,global_name
       ,(SELECT sys_context('USERENV','DB_UNIQUE_NAME') as unq_name FROM dual)           
       ,gv$instance i
    WHERE
        t.inst_id=i.inst_id
        AND t.thread#=(SELECT userenv('INSTANCE') FROM dual);
END;
/
column ins new_value ins
define ins=''
SELECT nvl(:ins||chr(10)||'SQL> ','SQL> ') ins FROM dual;
set sqlprompt "&&ins."
set term on trimout on trimspool on
undef ins