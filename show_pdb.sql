--
--  Script    : show_pdb.sql
--  Purpose   : show information FROM v$pdbs
--  Tested on : 12c,19c
--
@save_sqp_set

set lines 190 pages 50
col CON_ID          for 99 head 'Con'
col name            for a15
col restricted      for a10
col recovery_status for a15
col backup_status   for a15
col PDB_SIZE_GB     for 999,999,999.99
ttitle left 'v$pdbs'
SELECT
    con_id
   ,name
   ,open_mode
   ,restricted
   ,recovery_status
   ,total_size/1024/1024/1024 as PDB_SIZE_GB
FROM
    gv$pdbs
WHERE
    inst_id=to_number(sys_context('USERENV','INSTANCE'))
;

@rest_sqp_set
