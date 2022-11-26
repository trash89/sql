set timing off
drop table test;
drop table test_p;
create table test as select object_id,object_name,object_type from dba_objects
where 0=1;
create index test_idx on test(object_type);
create table test_p(
object_id number,
object_name varchar2(30),
object_type varchar2(18)
)
partition by range(object_type)
(
  partition p_cluster values less than ('CONSUMER GROUP'),
  partition p_consumer_group values less than ('DATABASE LINK'),
  partition p_database_link values less than ('FUNCTION'),
  partition p_function values less than ('INDEX'),
  partition p_index values less than ('INDEX PARTITION'),
  partition p_index_partition values less than ('LIBRARY'),
  partition p_library values less than ('LOB'),
  partition p_lob values less than ('PACKAGE'),
  partition p_package values less than ('PACKAGE BODY'),
  partition p_package_body values less than ('PROCEDURE'),
  partition p_procedure values less than ('QUEUE'),
  partition p_queue values less than ('RESOURCE PLAN'),
  partition p_resource_plan values less than ('SEQUENCE'),
  partition p_synonym values less than ('TABLE'),
  partition p_table values less than ('TABLE PARTITION'),
  partition p_table_partition values less than ('TRIGGER'),
  partition p_trigger values less than ('TYPE'),
  partition p_type values less than ('UNDEFINED'),
  partition p_undefined values less than ('VIEW'),
  partition p_view values less than (maxvalue)
);
create index test_p_idx on test_p(object_type) local;

insert /*+ APPEND */ into test 
select object_id,object_name,object_type from dba_objects
union all
select object_id,object_name,object_type from dba_objects
union all
select object_id,object_name,object_type from dba_objects;
commit;

insert /*+ APPEND */ into test_p 
select object_id,object_name,object_type from dba_objects
union all
select object_id,object_name,object_type from dba_objects
union all
select object_id,object_name,object_type from dba_objects;
commit;
analyze table test compute statistics for table for all columns;
analyze index test_idx compute statistics;
analyze table test_p compute statistics for table for all columns;
analyze index test_p_idx compute statistics;
set timing on 
select count(*) from test where object_type='TABLE';
select count(*) from test_p where object_type='TABLE';
