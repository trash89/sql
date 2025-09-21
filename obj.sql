--
--  Script    : obj.sql
--  Purpose   : show objects FROM dba_objects
--  Tested on : 10g+
--
@save_sqp_set

undef own
undef objtype
set lines 186 pages 50
accept own     char prompt 'Owner?(%)                        : ' default ''
accept objtype char prompt 'Object Type(TABLE,INDEX,etc)?(%) : ' default ''
col object_type     for a22     head 'Object Type'
col obj             for a60     head 'Object Name'
col subobject_name  for a30
col createdc        for a20     head 'Created'
col last_ddl_timec  for a20     head 'Last DDL'
col object_id       for 9999999 head 'Obj ID'
col temporary       for a4      head 'Temp'
col generated       for a3      head 'Gen'
col secondary       for a3      head 'Sec'
ttitle left 'dba_objects'
SELECT
  object_type
 ,owner||'.'||object_name                         as obj
 ,subobject_name
 ,to_char(created,'dd/mm/rrrr hh24:mi:ss')        as createdc
 ,to_char(last_ddl_time,'dd/mm/rrrr hh24:mi:ss')  as last_ddl_timec
 ,status
 ,object_id
 ,temporary
 ,generated
 ,secondary
FROM
  dba_objects
WHERE
  owner LIKE upper('%&&own%')
  AND object_type LIKE upper('%&&objtype%')
ORDER BY
  owner
 ,object_type
 ,object_name
 ,subobject_name
;

break on owner skip 1 nodup on report
compute sum label 'count by owner' of cnt on owner
compute sum of cnt on report
col owner for a30 head 'Owner'
SELECT
  owner
 ,object_type
 ,count(*) as cnt
FROM
  dba_objects
WHERE
  owner LIKE upper('%&&own%')
  AND object_type LIKE upper('%&&objtype%')
GROUP BY
  owner
 ,object_type
ORDER BY
  owner,object_type
;

undef own
undef objtype

@rest_sqp_set
