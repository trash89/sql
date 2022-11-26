col username for a15
col machine for a25
SELECT   b.SID,
         b.username,
         b.machine,
         SUM (a.blocks * 8 / 1024) used_mb
    FROM v$sort_usage a, v$session b
   WHERE a.session_addr = b.saddr(+)
GROUP BY b.SID, b.username, b.machine
ORDER BY used_mb DESC;
clear columns
