REM and a.sql_hash_value = b.hash_value
select buffer_gets, executions, buffer_gets/executions Ratio,sql_text from
v$session a, v$sql b 
where a.sql_address  = b.address
and a.sid = &&1;
