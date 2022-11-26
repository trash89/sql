set term off
variable ins varchar2(80 char)
variable hn varchar2(50 char)
begin
  select instance||':'||global_name||':'||user into :ins from v$thread,global_name where thread#=(select userenv('INSTANCE') from dual);
  select substr(host_name,0,instr(host_name,'.')-1)||':' into :hn from v$instance;
end;
/
column hn new_value hn
column ins new_value ins
define hn=''
define ins=''
select nvl(:hn||:ins||chr(10)||'SQL> ','SQL> ') ins from dual;
set sqlprompt "&&ins." 
set term on trimout on trimspool on lines 300 pages 100
undef hn
undef ins
