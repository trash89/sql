exec dbms_stats.drop_stat_table(ownname=>'SYS',stattab=>'MYSTATTABLE');
prompt create_stat_table
exec dbms_stats.create_stat_table(ownname=>'SYS',stattab=>'MYSTATTABLE',tblspace=>'SYSAUX');
prompt gather_fixed_objects_stats
exec dbms_stats.gather_fixed_objects_stats(stattab=>'MYSTATTABLE',statid=>'FIXED_OBJECTS',statown=>'SYS');
prompt gather_dictionary_stats
exec dbms_stats.gather_dictionary_stats(stattab=>'MYSTATTABLE',statid=>'DICTIONARY',statown=>'SYS');
prompt gather_system_stats NOWORKLOAD
exec dbms_stats.gather_system_stats('NOWORKLOAD',null,stattab=>'MYSTATTABLE',statid=>'SYSTEM_NOWORKLOAD',statown=>'SYS');
prompt gather_system_stats WORKLOAD START
exec dbms_stats.gather_system_stats('START',null,stattab=>'MYSTATTABLE',statid=>'SYSTEM_WORKLOAD',statown=>'SYS');

prompt delete_database_stats
exec dbms_stats.delete_database_stats;
prompt delete_dictionary_stats
exec dbms_stats.delete_dictionary_stats;
prompt delete_fixed_objects_stats
exec dbms_stats.delete_fixed_objects_stats;
prompt delete_system_stats
exec dbms_stats.delete_system_stats;

prompt gather_database_stats
exec dbms_stats.gather_database_stats(stattab=>'MYSTATTABLE',statid=>'DATABASE',statown=>'SYS');
prompt gather_system_stats WORKLOAD STOP
exec dbms_stats.gather_system_stats('STOP',null,stattab=>'MYSTATTABLE',statid=>'SYSTEM_WORKLOAD',statown=>'SYS');

prompt import_fixed_objects_stats
exec dbms_stats.import_fixed_objects_stats(stattab=>'MYSTATTABLE',statid=>'FIXED_OBJECTS',statown=>'SYS',force=>TRUE);
prompt import_dictionary_stats
exec dbms_stats.import_dictionary_stats(stattab=>'MYSTATTABLE',statid=>'DICTIONARY',statown=>'SYS',force=>TRUE);
prompt import_database_stats
exec dbms_stats.import_database_stats(stattab=>'MYSTATTABLE',statid=>'DATABASE',statown=>'SYS',force=>TRUE);
prompt import_system_stats NOWORKLOAD
exec dbms_stats.import_system_stats(stattab=>'MYSTATTABLE',statid=>'SYSTEM_NOWORKLOAD',statown=>'SYS');
prompt import_system_stats WORKLOAD
exec dbms_stats.import_system_stats(stattab=>'MYSTATTABLE',statid=>'SYSTEM_WORKLOAD',statown=>'SYS');

commit;

select * from sys.aux_stats$;
