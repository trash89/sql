---------------------------------
--- Detecting Gaps for Standby database
--- To be run on mounted standby database
---------------------------------
SELECT 
   high.thread#, "LowGap#", "HighGap#" 
FROM ( 
   SELECT thread#, MIN(sequence#)-1 "HighGap#" 
   FROM ( 
          SELECT a.thread#, a.sequence# 
          FROM ( 
                 SELECT * FROM v$archived_log 
               ) a, 
               ( SELECT thread#, MAX(next_change#)gap1 
                 FROM v$log_history GROUP BY thread# 
               ) b 
          WHERE 
               a.thread# = b.thread# AND 
               a.next_change# > gap1 
        ) 
   GROUP BY 
           thread# 
  ) high, 
     ( 
       SELECT thread#, MIN(sequence#) "LowGap#" 
       FROM ( 
              SELECT thread#, sequence# 
              FROM v$log_history, v$datafile 
              WHERE checkpoint_change# <= next_change# AND 
                    checkpoint_change# >= first_change# 
            ) 
       GROUP BY thread# 
     ) low 
   WHERE low.thread# = high.thread#;

