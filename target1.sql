MERGE /*+ APPEND PARALLEL(INC_SO_REQUISITION_ESH, DEFAULT, DEFAULT)  */ INTO "INC_SO_REQUISITION_ESH" USING (SELECT /*+ PARALLEL ("INC_TEC_ESH_DEC_BORNES",  DEFAULT, DEFAULT) PARALLEL ("INC_REQUISITION_ESH_1888589",  DEFAULT, DEFAULT) NO_MERGE  */ "INC_REQUISITION_ESH_1888589"."ID_REQ" "ID_REQ$1", "INC_REQUISITION_ESH_1888589"."EST_ACTIF" "EST_ACTIF$1", 
"INC_REQUISITION_ESH_1888589"."ID_DOC_WITH_VER" "ID_DOC_WITH_VER$1", "INC_REQUISITION_ESH_1888589"."NAME" "NAME$1", "INC_REQUISITION_ESH_1888589"."LOCKER" "LOCKER$1", "INC_REQUISITION_ESH_1888589"."DAT_CHKOU_EXP" "DAT_CHKOU_EXP$1", "INC_REQUISITION_ESH_1888589"."APP_STATE" "APP_STATE$1", "INC_REQUISITION_ESH_1888589"."APP_TOK" "APP_TOK$1", 
"INC_REQUISITION_ESH_1888589"."TYPE_REQ" "TYPE_REQ$1", "INC_REQUISITION_ESH_1888589"."DAT_HOLD_TILL" "DAT_HOLD_TILL$1", "INC_REQUISITION_ESH_1888589"."APP_REQ_VER" "APP_REQ_VER$1", "INC_REQUISITION_ESH_1888589"."LIB_STATUS" "LIB_STATUS$1", "INC_REQUISITION_ESH_1888589"."LIB_FOL_SUM" "LIB_FOL_SUM$1", "INC_REQUISITION_ESH_1888589"."DAT_LAST_MOD" "DAT_LAST_MOD$1", 
"INC_REQUISITION_ESH_1888589"."DAT_CRE_REQ" "DAT_CRE_REQ$1", "INC_REQUISITION_ESH_1888589"."DAT_SUBMIT" "DAT_SUBMIT$1", "INC_REQUISITION_ESH_1888589"."DAT_APP" "DAT_APP$1", "INC_REQUISITION_ESH_1888589"."NUM_VER" "NUM_VER$1", "INC_REQUISITION_ESH_1888589"."ID_DOC" "ID_DOC$1", "INC_REQUISITION_ESH_1888589"."ID_PRE" "ID_PRE$1", 
"INC_REQUISITION_ESH_1888589"."ID_ARIBA_BODY" "ID_ARIBA_BODY$1", "INC_REQUISITION_ESH_1888589"."DAT_ORD" "DAT_ORD$1", "INC_REQUISITION_ESH_1888589"."AED_ELEC" "AED_ELEC$1", "INC_REQUISITION_ESH_1888589"."UNQ_NAME_AED" "UNQ_NAME_AED$1", "INC_REQUISITION_ESH_1888589"."NAME_AED" "NAME_AED$1", "INC_REQUISITION_ESH_1888589"."CRT_ALR_SIG" "CRT_ALR_SIG$1", 
"INC_REQUISITION_ESH_1888589"."PRE_PAY_CCY" "PRE_PAY_CCY$1", "INC_REQUISITION_ESH_1888589"."PRE_PAY_AMT" "PRE_PAY_AMT$1", "INC_REQUISITION_ESH_1888589"."COMP_CRT" "COMP_CRT$1", "INC_REQUISITION_ESH_1888589"."PRE_PAY" "PRE_PAY$1", "INC_REQUISITION_ESH_1888589"."CRT_INC" "CRT_INC$1", "INC_REQUISITION_ESH_1888589"."NEED_HRA" "NEED_HRA$1", 
"INC_REQUISITION_ESH_1888589"."PLT_MAIN" "PLT_MAIN$1", "INC_REQUISITION_ESH_1888589"."PREVIOUSVERSION" "PREVIOUSVERSION$1", "INC_REQUISITION_ESH_1888589"."NEXTVERSION" "NEXTVERSION$1", "INC_REQUISITION_ESH_1888589"."COD_MOIS_REQ" "COD_MOIS_REQ$1", "INC_REQUISITION_ESH_1888589"."COD_ANN_REQ" "COD_ANN_REQ$1", 
"INC_REQUISITION_ESH_1888589"."VALIDE_PAR" "VALIDE_PAR$1", "INC_REQUISITION_ESH_1888589"."ID_CCE" "ID_CCE$1", "INC_REQUISITION_ESH_1888589"."PREPARE_PAR" "PREPARE_PAR$1", "INC_REQUISITION_ESH_1888589"."MODIFIE_PAR" "MODIFIE_PAR$1", "INC_REQUISITION_ESH_1888589"."ID_GLCE" "ID_GLCE$1", "INC_REQUISITION_ESH_1888589"."DEMANDE_PAR" "DEMANDE_PAR$1", 
"INC_REQUISITION_ESH_1888589"."DAT_MAJ_ESH" "DAT_MAJ_ESH$1", "INC_REQUISITION_ESH_1888589"."DAT_CRE" "DAT_CRE$1", "INC_REQUISITION_ESH_1888589"."USER_CRE" "USER_CRE$1", "INC_REQUISITION_ESH_1888589"."DAT_MAJ" "DAT_MAJ$1", "INC_REQUISITION_ESH_1888589"."USER_MAJ" "USER_MAJ$1" 
FROM 
  "INC_TEC_ESH_DEC_BORNES" "INC_TEC_ESH_DEC_BORNES", 
  "INC_O_OWN"."INC_REQUISITION_ESH"@"DAG01TP@CNT_INCA_DEC_TRA" "INC_REQUISITION_ESH_1888589" 
WHERE ( "INC_TEC_ESH_DEC_BORNES"."ID_TEB"= 1 ) AND ( "INC_REQUISITION_ESH_1888589"."DAT_MAJ" >= NVL ( "INC_REQUISITION_ESH_1888589"."DAT_MAJ" , TO_DATE ( '01/01/2000' , 'dd/mm/yy' ) ) ) ) "MERGEQUERY_688" 
ON ( "INC_SO_REQUISITION_ESH"."ID_REQ" = "MERGEQUERY_688"."ID_REQ$1" ) 
WHEN NOT MATCHED THEN 
  INSERT ("INC_SO_REQUISITION_ESH"."ID_REQ", "INC_SO_REQUISITION_ESH"."EST_ACTIF", "INC_SO_REQUISITION_ESH"."ID_DOC_WITH_VER", "INC_SO_REQUISITION_ESH"."NAME", "INC_SO_REQUISITION_ESH"."LOCKER", "INC_SO_REQUISITION_ESH"."DAT_CHKOU_EXP", "INC_SO_REQUISITION_ESH"."APP_STATE", "INC_SO_REQUISITION_ESH"."APP_TOK", 
"INC_SO_REQUISITION_ESH"."TYPE_REQ", "INC_SO_REQUISITION_ESH"."DAT_HOLD_TILL", "INC_SO_REQUISITION_ESH"."APP_REQ_VER", "INC_SO_REQUISITION_ESH"."LIB_STATUS", "INC_SO_REQUISITION_ESH"."LIB_FOL_SUM", "INC_SO_REQUISITION_ESH"."DAT_LAST_MOD", "INC_SO_REQUISITION_ESH"."DAT_CRE_REQ", "INC_SO_REQUISITION_ESH"."DAT_SUBMIT", 
"INC_SO_REQUISITION_ESH"."DAT_APP", "INC_SO_REQUISITION_ESH"."NUM_VER", "INC_SO_REQUISITION_ESH"."ID_DOC", "INC_SO_REQUISITION_ESH"."ID_PRE", "INC_SO_REQUISITION_ESH"."ID_ARIBA_BODY", "INC_SO_REQUISITION_ESH"."DAT_ORD", "INC_SO_REQUISITION_ESH"."AED_ELEC", "INC_SO_REQUISITION_ESH"."UNQ_NAME_AED", 
"INC_SO_REQUISITION_ESH"."NAME_AED", "INC_SO_REQUISITION_ESH"."CRT_ALR_SIG", "INC_SO_REQUISITION_ESH"."PRE_PAY_CCY", "INC_SO_REQUISITION_ESH"."PRE_PAY_AMT", "INC_SO_REQUISITION_ESH"."COMP_CRT", "INC_SO_REQUISITION_ESH"."PRE_PAY", "INC_SO_REQUISITION_ESH"."CRT_INC", "INC_SO_REQUISITION_ESH"."NEED_HRA", 
"INC_SO_REQUISITION_ESH"."PLT_MAIN", "INC_SO_REQUISITION_ESH"."PREVIOUSVERSION", "INC_SO_REQUISITION_ESH"."NEXTVERSION", "INC_SO_REQUISITION_ESH"."COD_MOIS_REQ", "INC_SO_REQUISITION_ESH"."COD_ANN_REQ", "INC_SO_REQUISITION_ESH"."VALIDE_PAR", "INC_SO_REQUISITION_ESH"."ID_CCE", "INC_SO_REQUISITION_ESH"."PREPARE_PAR", 
"INC_SO_REQUISITION_ESH"."MODIFIE_PAR", "INC_SO_REQUISITION_ESH"."ID_GLCE", "INC_SO_REQUISITION_ESH"."DEMANDE_PAR", "INC_SO_REQUISITION_ESH"."DAT_MAJ_ESH", "INC_SO_REQUISITION_ESH"."DAT_CRE", "INC_SO_REQUISITION_ESH"."USER_CRE", "INC_SO_REQUISITION_ESH"."DAT_MAJ", "INC_SO_REQUISITION_ESH"."USER_MAJ") 
VALUES ("MERGEQUERY_688"."ID_REQ$1", "MERGEQUERY_688"."EST_ACTIF$1", "MERGEQUERY_688"."ID_DOC_WITH_VER$1", "MERGEQUERY_688"."NAME$1", "MERGEQUERY_688"."LOCKER$1", "MERGEQUERY_688"."DAT_CHKOU_EXP$1", "MERGEQUERY_688"."APP_STATE$1", "MERGEQUERY_688"."APP_TOK$1", "MERGEQUERY_688"."TYPE_REQ$1", "MERGEQUERY_688"."DAT_HOLD_TILL$1", 
"MERGEQUERY_688"."APP_REQ_VER$1", "MERGEQUERY_688"."LIB_STATUS$1", "MERGEQUERY_688"."LIB_FOL_SUM$1", "MERGEQUERY_688"."DAT_LAST_MOD$1", "MERGEQUERY_688"."DAT_CRE_REQ$1", "MERGEQUERY_688"."DAT_SUBMIT$1", "MERGEQUERY_688"."DAT_APP$1", "MERGEQUERY_688"."NUM_VER$1", "MERGEQUERY_688"."ID_DOC$1", "MERGEQUERY_688"."ID_PRE$1", 
"MERGEQUERY_688"."ID_ARIBA_BODY$1", "MERGEQUERY_688"."DAT_ORD$1", "MERGEQUERY_688"."AED_ELEC$1", "MERGEQUERY_688"."UNQ_NAME_AED$1", "MERGEQUERY_688"."NAME_AED$1", "MERGEQUERY_688"."CRT_ALR_SIG$1", "MERGEQUERY_688"."PRE_PAY_CCY$1", "MERGEQUERY_688"."PRE_PAY_AMT$1", "MERGEQUERY_688"."COMP_CRT$1", "MERGEQUERY_688"."PRE_PAY$1", 
"MERGEQUERY_688"."CRT_INC$1", "MERGEQUERY_688"."NEED_HRA$1", "MERGEQUERY_688"."PLT_MAIN$1", "MERGEQUERY_688"."PREVIOUSVERSION$1", "MERGEQUERY_688"."NEXTVERSION$1", "MERGEQUERY_688"."COD_MOIS_REQ$1", "MERGEQUERY_688"."COD_ANN_REQ$1", "MERGEQUERY_688"."VALIDE_PAR$1", "MERGEQUERY_688"."ID_CCE$1", "MERGEQUERY_688"."PREPARE_PAR$1", 
"MERGEQUERY_688"."MODIFIE_PAR$1", "MERGEQUERY_688"."ID_GLCE$1", "MERGEQUERY_688"."DEMANDE_PAR$1", "MERGEQUERY_688"."DAT_MAJ_ESH$1", "MERGEQUERY_688"."DAT_CRE$1", "MERGEQUERY_688"."USER_CRE$1","MERGEQUERY_688"."DAT_MAJ$1", "MERGEQUERY_688"."USER_MAJ$1") WHEN MATCHED THEN UPDATE SET "EST_ACTIF" = "MERGEQUERY_688"."EST_ACTIF$1", 
"ID_DOC_WITH_VER" = "MERGEQUERY_688"."ID_DOC_WITH_VER$1", "NAME" = "MERGEQUERY_688"."NAME$1", "LOCKER" = "MERGEQUERY_688"."LOCKER$1", "DAT_CHKOU_EXP" = "MERGEQUERY_688"."DAT_CHKOU_EXP$1", "APP_STATE" = "MERGEQUERY_688"."APP_STATE$1", "APP_TOK" = "MERGEQUERY_688"."APP_TOK$1", "TYPE_REQ" = "MERGEQUERY_688"."TYPE_REQ$1", 
"DAT_HOLD_TILL" = "MERGEQUERY_688"."DAT_HOLD_TILL$1", "APP_REQ_VER" = "MERGEQUERY_688"."APP_REQ_VER$1", "LIB_STATUS" = "MERGEQUERY_688"."LIB_STATUS$1", "LIB_FOL_SUM" = "MERGEQUERY_688"."LIB_FOL_SUM$1", "DAT_LAST_MOD" = "MERGEQUERY_688"."DAT_LAST_MOD$1", "DAT_CRE_REQ" = "MERGEQUERY_688"."DAT_CRE_REQ$1", 
"DAT_SUBMIT" = "MERGEQUERY_688"."DAT_SUBMIT$1", "DAT_APP" = "MERGEQUERY_688"."DAT_APP$1", "NUM_VER" = "MERGEQUERY_688"."NUM_VER$1", "ID_DOC" = "MERGEQUERY_688"."ID_DOC$1", "ID_PRE" = "MERGEQUERY_688"."ID_PRE$1", "ID_ARIBA_BODY" = "MERGEQUERY_688"."ID_ARIBA_BODY$1", "DAT_ORD" = "MERGEQUERY_688"."DAT_ORD$1", 
"AED_ELEC" = "MERGEQUERY_688"."AED_ELEC$1", "UNQ_NAME_AED" = "MERGEQUERY_688"."UNQ_NAME_AED$1", "NAME_AED" = "MERGEQUERY_688"."NAME_AED$1", "CRT_ALR_SIG" = "MERGEQUERY_688"."CRT_ALR_SIG$1", "PRE_PAY_CCY" = "MERGEQUERY_688"."PRE_PAY_CCY$1", "PRE_PAY_AMT" = "MERGEQUERY_688"."PRE_PAY_AMT$1", "COMP_CRT" = "MERGEQUERY_688"."COMP_CRT$1", 
"PRE_PAY" = "MERGEQUERY_688"."PRE_PAY$1", "CRT_INC" = "MERGEQUERY_688"."CRT_INC$1", "NEED_HRA" = "MERGEQUERY_688"."NEED_HRA$1", "PLT_MAIN" = "MERGEQUERY_688"."PLT_MAIN$1", "PREVIOUSVERSION" = "MERGEQUERY_688"."PREVIOUSVERSION$1", "NEXTVERSION" = "MERGEQUERY_688"."NEXTVERSION$1", "COD_MOIS_REQ" = "MERGEQUERY_688"."COD_MOIS_REQ$1", 
"COD_ANN_REQ" = "MERGEQUERY_688"."COD_ANN_REQ$1", "VALIDE_PAR" = "MERGEQUERY_688"."VALIDE_PAR$1", "ID_CCE" = "MERGEQUERY_688"."ID_CCE$1", "PREPARE_PAR" = "MERGEQUERY_688"."PREPARE_PAR$1", "MODIFIE_PAR" = "MERGEQUERY_688"."MODIFIE_PAR$1", "ID_GLCE" = "MERGEQUERY_688"."ID_GLCE$1", "DEMANDE_PAR" = "MERGEQUERY_688"."DEMANDE_PAR$1", "DAT_MAJ_ESH" = "MERGEQUERY_688"."DAT_MAJ_ESH$1", "DAT_MAJ" = "MERGEQUERY_688"."DAT_MAJ$1", "USER_MAJ" = "MERGEQUERY_688"."USER_MAJ$1"
;

