--
--  Script    : f_all.sql
--  Purpose   : show datafile information in multitenant
--  Tested on : 12c,19c,23c
--
@save_sqp_set

set lines 197 pages 50 
set feed off

col con_id                          for 999         head 'Con'
col TABLESPACE_NAME                 for a30
col status                          for a9          head 'Status'
col enabled                         for a10         head 'Enabled'
col bigfile                         for a4          head 'BigF'
col flashback_on                    for a3          head 'Flb'
col included_in_database_backup     for a3          head 'Bck'
col incr                            for 999,999     head "Inc(MB)"
col MEG                             for 99,999,999  head 'Size(MB)'
col file_id                         for 9999        head "Id"
col FILE_NAME                       for a100

ttitle left 'Datafiles AND tempfiles'
break on con_id on report
compute sum of meg on con_id 
compute sum of meg on report
SELECT * FROM (
SELECT
     ddf.con_id
    ,ddf.tablespace_name
    ,df.status
    ,df.enabled
    ,t.bigfile
    ,t.flashback_on
    ,t.included_in_database_backup
    ,(ddf.increment_by*to_number(p.value))/1024/1024 as incr
    ,df.bytes/1024/1024 as meg
    ,ddf.file_id   
    ,ddf.file_name
FROM
    cdb_data_files ddf
   ,gv$tablespace t
   ,gv$datafile df
   ,gv$parameter p
WHERE
    t.inst_id=df.inst_id
    AND t.inst_id=to_number(sys_context('USERENV','INSTANCE'))
    AND ddf.con_id=t.con_id
    AND ddf.con_id=t.con_id
    AND ddf.con_id=df.con_id
    AND t.ts#=df.ts#
    AND p.name='db_block_size'
    AND df.file#=ddf.file_id
    AND ddf.tablespace_name=t.name
union all
SELECT
     dtf.con_id
    ,dtf.tablespace_name
    ,dtf.status
    ,lpad(' ',9) as enabled
    ,t.bigfile
    ,t.flashback_on
    ,t.included_in_database_backup
    ,(dtf.increment_by*to_number(p.value))/1024/1024 as incr   
    ,dtf.bytes/1024/1024 as meg
    ,dtf.file_id   
    ,dtf.file_name
FROM
     cdb_temp_files dtf
    ,gv$tablespace t
    ,gv$parameter p
WHERE
    dtf.tablespace_name=t.name
    AND p.name='db_block_size'
    AND t.inst_id=to_number(sys_context('USERENV','INSTANCE'))
    AND dtf.con_id=t.con_id
    AND dtf.con_id=t.con_id
)
ORDER BY
     con_id
    ,tablespace_name
    ,file_name
;

@rest_sqp_set
