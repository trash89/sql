--
--  Script    : gather_schema_stats.sql
--  Purpose   : Gather schema statistics
--  Tested on : 10g+
--
@save_sqp_set

set head on autoprint on echo off show off tab off termout on newp none feed on
undef sch
accept sch char prompt 'Schema? : ' default 'SCOTT'

prompt exec dbms_stats.gather_schema_stats(ownname=>upper('&&sch'),degree=> DBMS_STATS.DEFAULT_DEGREE,estimate_percent=>100,cascade=>true,options=>'GATHER AUTO',granularity=>'ALL',method_opt=>'FOR ALL COLUMNS SIZE AUTO');
exec dbms_stats.gather_schema_stats(ownname=>upper('&&sch'),degree=> DBMS_STATS.DEFAULT_DEGREE,estimate_percent=>100,cascade=>true,options=>'GATHER AUTO',granularity=>'ALL',method_opt=>'FOR ALL COLUMNS SIZE AUTO');

undef sch

@rest_sqp_set
