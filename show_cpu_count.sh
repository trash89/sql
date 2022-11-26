sqlplus -s / << EOF
set feedback off pagesize 0 heading off verify off linesize 100 trimspool on
variable v_cpu_count number
begin
  :v_cpu_count:=0;
  select value into :v_cpu_count from v\$parameter where upper(name) like upper('%cpu_count%');
end;
/
exit :v_cpu_count
EOF
echo $?
