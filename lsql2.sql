select sql_text from
v$session a, v$sqltext_with_newlines b
where a.sql_address  = b.address
and a.sid = &&1
order by piece
/
