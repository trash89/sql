------------------- begin check_object_types.sql -------------------------------
-

column owner       format a20
column object_name format a30
column object_type format a10
column data_type   format a15

SET PAGES 999 
SET LINES 80
SET FEEDBACK OFF
SET SERVEROUT ON 
SET PAUSE OFF 
SET VERIFY OFF 

ACCEPT ord_object_type_list  PROMPT 'Enter the object types to be checked: '


SELECT a.owner, a.object_name, a.object_type,d.data_type    FROM   dba_objects 
a , dba_tab_columns d
WHERE a.object_id IN
 (SELECT b.d_obj#  FROM   dependency$ b
  WHERE b.P_obj#
  IN (
     SELECT c.object_id FROM dba_objects c
     WHERE c.owner = 'ORDSYS'
     AND c.object_type = 'TYPE'
     AND c.object_name in ('&ord_object_type_list')))
AND  a.object_type = 'TABLE'
AND  d.owner = a.owner
AND  d.table_name = a.object_name
AND  d.data_type IN  ('&ord_object_type_list');
set feedback on
SET VERIFY On
------------------- end check_object_types.sql --------------------------------
