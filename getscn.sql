--
--  Script    : getscn.sql
--  Purpose   : determine the instantiation scn of the database
--  Tested on : 10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 50 pages 50

SELECT MIN(SCN) as INSTANTIATION_SCN
  FROM (SELECT MIN(START_SCN) as SCN 
        FROM gv$transaction 
        UNION ALL 
        SELECT CURRENT_SCN FROM gv$database
      );

@rest_sqp_set