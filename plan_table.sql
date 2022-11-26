drop table plan_table;
drop public synonym plan_table;
@?/rdbms/admin/utlxplan
--@c:\oracle\10gr2/rdbms/admin/utlxplan
create public synonym plan_table for plan_table;
grant all on plan_table to public;
create index plan_table_idx on plan_table(id,parent_id);


