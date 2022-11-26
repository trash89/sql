drop table test cascade constraints;
create table test( 
         owner varchar2(30), 
         object_name varchar2(128), 
         object_id number,
         object_type varchar2(18),
         created date
)
partition by range(object_type) 
--subpartition by hash(object_id) subpartitions 4
(
  partition p_cluster values less than ('CONSUMER GROUP'),
  partition p_consumer_group values less than ('DATABASE LINK'),
  partition p_database_link values less than ('FUNCTION'),
  partition p_function values less than ('INDEX'),
  partition p_index values less than ('LIBRARY'),
  partition p_library values less than ('LOB'),
  partition p_lob values less than ('PACKAGE'),
  partition p_package values less than ('PACKAGE BODY'),
  partition p_package_body values less than ('PROCEDURE'),
  partition p_procedure values less than ('QUEUE'),
  partition p_queue values less than ('RESOURCE PLAN'),
  partition p_resource_plan values less than ('SEQUENCE'),
  partition p_sequence values less than ('SYNONYM'),
  partition p_synonym values less than ('TABLE'),
  partition p_table values less than ('TRIGGER'),
  partition p_trigger values less than ('TYPE'),
  partition p_type values less than ('VIEW'),
  partition p_view values less than ('Y'),
  partition p_others values less than (maxvalue)
)
enable row movement;
insert into test select owner,object_name,object_id,object_type,created from dba_objects where object_id is not null;
commit;
alter table test add constraint pk_test primary key(object_id,object_type)
using index local;
analyze table test compute statistics for table for all indexes for all columns size 75;
