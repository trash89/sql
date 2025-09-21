--
--  Script    : init.sql
--  Purpose   : Show the v$parameter system parameters currently in efect
--  Tested on : 12c,19c,23c
--
@save_sqp_set

set lines 180 pages 50 trimout on 

col name        for a43     head 'Name'
col value       for a94     head 'Value'
col ses         for a8      head 'Sess?'
col sysm        for a9      head 'Sys?'
col pdb         for a9      head 'PDB?'
col inst        for a9      head 'Inst?'
ttitle left 'v$parameter'
SELECT
    name
   ,value
   ,isses_modifiable      AS ses
   ,issys_modifiable      AS sysm
   ,ispdb_modifiable      AS pdb
   ,isinstance_modifiable AS inst
FROM
    gv$parameter
WHERE
    isdefault='FALSE' or ismodified!='FALSE'
    AND inst_id=to_number(sys_context('USERENV','INSTANCE'))
ORDER BY
    name
;

@rest_sqp_set
