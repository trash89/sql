--
--  Script    : idx_fk.sql
--  Purpose   : check if FK columns have indexes to prevent a possible locking problem that can slow down the database.
--  Tested on : 8i,9i,10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 189 pages 50 trims off trim on 
undef own
accept own char prompt 'Owner?(%)      : '

col status    for a6
col tab       for a60 head 'Table Name'
col cols      for a60

SELECT
  decode(b.table_name,NULL,'****','ok') status
 ,a.owner||'.'||a.table_name as tab
 ,a.cols
 ,b.cols
FROM
  (
    SELECT
      a.owner
     ,a.table_name
     ,a.constraint_name
     ,max(decode(position,1,column_name,NULL))||max(decode(position,2,', '||column_name,NULL))||max(decode(position,3,', '||column_name,NULL))||max(decode(position,4,', '||column_name,NULL))||max(decode(position,5,', '||column_name,NULL))||max(decode(position,6,', '||column_name,NULL))||max(decode(position,7,', '||column_name,NULL))||max(decode(position,8,', '||column_name,NULL))||max(decode(position,9,', '||column_name,NULL))||max(decode(position,10,', '||column_name,NULL))||max(decode(position,11,', '||column_name,NULL))||max(decode(position,12,', '||column_name,NULL))||max(decode(position,13,', '||column_name,NULL))||max(decode(position,14,', '||column_name,NULL))||max(decode(position,15,', '||column_name,NULL))||max(decode(position,16,', '||column_name,NULL)) as cols
    FROM
      dba_cons_columns a
     ,dba_constraints  b
    WHERE
      a.owner=b.owner
      AND a.owner=upper('&&own')
      AND a.constraint_name=b.constraint_name
      AND b.constraint_type='R'
    GROUP BY
      a.owner
     ,a.table_name
     ,a.constraint_name
  ) a
 ,(
    SELECT
      index_owner
     ,table_name
     ,index_name
     ,max(decode(column_position,1,column_name,NULL))||max(decode(column_position,2,', '||column_name,NULL))||max(decode(column_position,3,', '||column_name,NULL))||max(decode(column_position,4,', '||column_name,NULL))||max(decode(column_position,5,', '||column_name,NULL))||max(decode(column_position,6,', '||column_name,NULL))||max(decode(column_position,7,', '||column_name,NULL))||max(decode(column_position,8,', '||column_name,NULL))||max(decode(column_position,9,', '||column_name,NULL))||max(decode(column_position,10,', '||column_name,NULL))||max(decode(column_position,11,', '||column_name,NULL))||max(decode(column_position,12,', '||column_name,NULL))||max(decode(column_position,13,', '||column_name,NULL))||max(decode(column_position,14,', '||column_name,NULL))||max(decode(column_position,15,', '||column_name,NULL))||max(decode(column_position,16,', '||column_name,NULL)) as cols
    FROM
      dba_ind_columns
    WHERE 
       index_owner=upper('&&own')
    GROUP BY
      index_owner
     ,table_name
     ,index_name
  ) b
WHERE
  a.table_name=b.table_name(+)
  AND b.cols(+) LIKE a.cols||'%'
;

@rest_sqp_set
