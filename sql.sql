select
        username,
        sql_text 
from 
        v$session       ses,
        v$sql           sql
where
        sql.hash_value = ses.sql_hash_value + decode(sign(ses.sql_hash_value),-1,power(2,32),0)
and     sql.address = ses.sql_address
and     sid = &sid;
