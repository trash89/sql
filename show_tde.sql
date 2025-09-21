--
--  Script    : show_tde.sql
--  Purpose   : show encrypted columns FROM dba_encrypted_columns, also v$encryption_wallet and v$encryption_keys
--  Tested on : 12c,19c
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
col CON_ID              for 99  head 'Con'
col status              for a30
col WRL_TYPE            for a20
col WALLET_TYPE         for a20
col WALLET_ORDER        for a9  head 'W order'
col FULLY_BACKED_UP     for a9  head 'Backuped'
col keystore_mode       for a8  head 'Mode'
col WRL_PARAMETER       for a80
ttitle left 'v$encryption_wallet'
SELECT 
     CON_ID
    ,status
    ,WRL_TYPE    
    ,WALLET_TYPE
    ,WALLET_ORDER
    ,FULLY_BACKED_UP
--    ,keystore_mode
    ,WRL_PARAMETER
FROM 
    gv$encryption_wallet
WHERE
    inst_id=to_number(sys_context('USERENV','INSTANCE'))    
ORDER BY
     CON_ID
    ,status
    ,WRL_TYPE
;

col KEY_ID          for a70
col tag             for a30
col user            for a30
col key_use         for a10
col KEYSTORE_TYPE   for a17
col BACKED_UP       for a9
col CON_ID          for 99 head 'Con'
ttitle left 'v$encryption_keys'
SELECT 
     CON_ID 
    ,KEY_ID
    ,tag
    ,USER
    ,KEY_USE
    ,KEYSTORE_TYPE
    ,BACKED_UP
FROM 
    gv$encryption_keys
WHERE
    inst_id=to_number(sys_context('USERENV','INSTANCE'))    
ORDER BY
     CON_ID
    ,user    
;

set feed on
ttitle off
col creation_timec      for a19 head 'Creation Time'
col activation_timec    for a19 head 'Activation Time'
col creator             for a50 head 'Creator:DBNAME/PDBNAME'
col activating          for a50 head 'Activating:DBNAME/PDBNAME'
SELECT 
     to_char(creation_time,'dd/mm/yyyy hh24:mi:ss')     as creation_timec 
    ,to_char(activation_time,'dd/mm/yyyy hh24:mi:ss')   as activation_timec
    ,creator_dbname||'/'||creator_pdbname               as creator
    ,activating_dbname||'/'||activating_pdbname         as activating
FROM    
    gv$encryption_keys
WHERE
    inst_id=to_number(sys_context('USERENV','INSTANCE'))    
ORDER BY
     CON_ID
    ,user    
;

rem Clean database ( no encryption enabled )
rem 11g
rem BITAND(FLAGS,8) == 0
rem 12c+
rem mkloc == 0

set feed off
ttitle left 'sys.x$kcbdbk, if mkloc == 0, no encryption enabled'
SELECT 
     con_id
    ,mkloc 
FROM 
    sys.x$kcbdbk
;

@rest_sqp_set
