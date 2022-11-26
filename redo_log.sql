 select first_time,to_char(first_time,'mm/dd/yy hh24:mi:ss') ft,bytes/1024/1024 from v$log order by first_time desc
/
