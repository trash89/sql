rem Transactions per second
SELECT s.value/((sysdate-i.startup_time)*86400) as tx_per_sec
FROM v$sysstat s, v$instance i
WHERE s.name = 'user calls';
