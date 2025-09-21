--
--  Script    : gather_db_stats.sql
--  Purpose   : Gather database statistics, fixed objects stats, dictionary stats and all database stats
--  Tested on : 10g+
--
prompt Calculating database stats, please wait ...

prompt exec dbms_stats.gather_fixed_objects_stats;
exec dbms_stats.gather_fixed_objects_stats;

prompt exec dbms_stats.gather_dictionary_stats();
exec dbms_stats.gather_dictionary_stats();

prompt exec dbms_stats.gather_database_stats(estimate_percent=>100,degree=> DBMS_STATS.DEFAULT_DEGREE,cascade=>true,options=>'GATHER AUTO',granularity=>'ALL',method_opt=>'FOR ALL COLUMNS SIZE AUTO');
exec dbms_stats.gather_database_stats(estimate_percent=>100,degree=> DBMS_STATS.DEFAULT_DEGREE,cascade=>true,options=>'GATHER AUTO',granularity=>'ALL',method_opt=>'FOR ALL COLUMNS SIZE AUTO');

-- for one schema
-- exec dbms_stats.gather_schema_stats(ownname=>'SCOTT',degree=> DBMS_STATS.DEFAULT_DEGREE,estimate_percent=>100,cascade=>true,options=>'GATHER AUTO',granularity=>'ALL',method_opt=>'FOR ALL COLUMNS SIZE AUTO');

-- for one table
-- exec dbms_stats.gather_table_stats(ownname=>'SCOTT',tabname=>'STRESSTESTTABLE',degree=> DBMS_STATS.DEFAULT_DEGREE,estimate_percent=>100,cascade=>true,options=>'GATHER AUTO',granularity=>'ALL',method_opt=>'FOR ALL COLUMNS SIZE AUTO');
