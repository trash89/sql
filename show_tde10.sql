--
--  Script    : show_tde10.sql
--  Purpose   : show encrypted columns FROM dba_encrypted_columns, also v$encryption_wallet and v$encryption_keys
--  Tested on : 10g,11g
--
@save_sqp_set

set lines 191 pages 50 

col tab             for a60 head 'Table'
col column_name     for a30
col ENCRYPTION_ALG  for a30 head 'Encryption Alg'
col INTEGRITY_ALG   for a12 head 'Integrity Alg'
ttitle left 'dba_encrypted_columns'
SELECT 
     owner||'.'||table_name as tab
    ,column_name
    ,ENCRYPTION_ALG
    ,INTEGRITY_ALG
FROM 
    dba_encrypted_columns
ORDER BY
     1
    ,2
;

set feed off
col status              for a30
col WRL_TYPE            for a20
col WRL_PARAMETER       for a80
ttitle left 'v$encryption_wallet'
SELECT 
     status
    ,WRL_TYPE    
    ,WRL_PARAMETER
FROM 
    gv$encryption_wallet
WHERE
    inst_id=to_number(sys_context('USERENV','INSTANCE'))    
ORDER BY
     status
    ,WRL_TYPE
;

@rest_sqp_set
