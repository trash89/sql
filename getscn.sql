--
--  Script    : getscn.sql
--  Purpose   : determine the instantiation scn of the database
--  Tested on : 11g,12c,19c,23c
--
@save_sqp_set

set lines 50 pages 50

prompt exec dbms_stats.gather_dictionary_stats();
exec dbms_stats.gather_dictionary_stats();

ALTER SYSTEM SWITCH LOGFILE;
SELECT min(scn) as instantiation_scn
  FROM (SELECT min(start_scn) as scn
        FROM gv$transaction 
        UNION ALL 
        SELECT current_scn FROM gv$database
      );
ALTER SYSTEM SWITCH LOGFILE;

@rest_sqp_set