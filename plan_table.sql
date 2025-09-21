DROP TABLE plan_table;
DROP PUBLIC SYNONYM plan_table;
@?/rdbms/admin/utlxplan
CREATE PUBLIC SYNONYM plan_table FOR plan_table;
GRANT ALL ON plan_table TO PUBLIC;
CREATE INDEX plan_table_idx ON plan_table(id,parent_id);