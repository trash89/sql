--
--  Script    : gather_table_stats.sql
--  Purpose   : Gather table statistics
--  Tested on : 10g+
--
@save_sqp_set

set head on autoprint on echo off show off tab off termout on newp none feed on
undef sch
undef tab
accept sch char prompt 'Schema? : ' default 'SCOTT'
accept tab char prompt 'Table?  : ' default 'TEST'

prompt exec dbms_stats.gather_table_stats(ownname=>upper('&&sch'),tabname=>upper('&&tab'),degree=> DBMS_STATS.DEFAULT_DEGREE,estimate_percent=>100,cascade=>true,options=>'GATHER AUTO',granularity=>'ALL',method_opt=>'FOR ALL COLUMNS SIZE AUTO');
exec dbms_stats.gather_table_stats(ownname=>upper('&&sch'),tabname=>upper('&&tab'),degree=> DBMS_STATS.DEFAULT_DEGREE,estimate_percent=>100,cascade=>true,options=>'GATHER AUTO',granularity=>'ALL',method_opt=>'FOR ALL COLUMNS SIZE AUTO');

undef sch
undef tab

@rest_sqp_set
