select /*+  no_parallel(t) no_parallel_index(t) dbms_stats cursor_sharing_exact use_weak_name_resl dynamic_sampling(0) no_monitoring xmlindex_sel_idx_tbl opt_param('optimizer_inmemory_aware' 'false')
no_substrb_pad  */count(*), count("OWNER"), count(distinct "OWNER"), sum(sys_op_opnsize("OWNER")), substrb(dump(min(substrb("OWNER",1,64)),16,0,64),1,240), substrb(dump(max(substrb("OWNER",1,64)),16,0
,64),1,240), count("OBJECT_NAME"), count(distinct "OBJECT_NAME"), sum(sys_op_opnsize("OBJECT_NAME")), substrb(dump(min(substrb("OBJECT_NAME",1,64)),16,0,64),1,240), substrb(dump(max(substrb("OBJECT_NA
ME",1,64)),16,0,64),1,240), count("SUBOBJECT_NAME"), count(distinct "SUBOBJECT_NAME"), sum(sys_op_opnsize("SUBOBJECT_NAME")), substrb(dump(min(substrb("SUBOBJECT_NAME",1,64)),16,0,64),1,240), substrb(
dump(max(substrb("SUBOBJECT_NAME",1,64)),16,0,64),1,240), count("OBJECT_ID"), sum(sys_op_opnsize("OBJECT_ID")), count("DATA_OBJECT_ID"), count(distinct "DATA_OBJECT_ID"), sum(sys_op_opnsize("DATA_OBJE
CT_ID")), substrb(dump(min("DATA_OBJECT_ID"),16,0,64),1,240), substrb(dump(max("DATA_OBJECT_ID"),16,0,64),1,240), count("OBJECT_TYPE"), sum(sys_op_opnsize("OBJECT_TYPE")), count("CREATED"), count(dist
inct "CREATED"), substrb(dump(min("CREATED"),16,0,64),1,240), substrb(dump(max("CREATED"),16,0,64),1,240), count("LAST_DDL_TIME"), count(distinct "LAST_DDL_TIME"), substrb(dump(min("LAST_DDL_TIME"),16
,0,64),1,240), substrb(dump(max("LAST_DDL_TIME"),16,0,64),1,240), count("TIMESTAMP"), count(distinct "TIMESTAMP"), sum(sys_op_opnsize("TIMESTAMP")), substrb(dump(min("TIMESTAMP"),16,0,64),1,240), subs
trb(dump(max("TIMESTAMP"),16,0,64),1,240), count("STATUS"), count(distinct "STATUS"), sum(sys_op_opnsize("STATUS")), substrb(dump(min("STATUS"),16,0,64),1,240), substrb(dump(max("STATUS"),16,0,64),1,2
40), count("TEMPORARY"), count(distinct "TEMPORARY"), sum(sys_op_opnsize("TEMPORARY")), substrb(dump(min("TEMPORARY"),16,0,64),1,240), substrb(dump(max("TEMPORARY"),16,0,64),1,240), count("GENERATED")
, count(distinct "GENERATED"), sum(sys_op_opnsize("GENERATED")), substrb(dump(min("GENERATED"),16,0,64),1,240), substrb(dump(max("GENERATED"),16,0,64),1,240), count("SECONDARY"), count(distinct "SECON
DARY"), sum(sys_op_opnsize("SECONDARY")), substrb(dump(min("SECONDARY"),16,0,64),1,240), substrb(dump(max("SECONDARY"),16,0,64),1,240), count("NAMESPACE"), count(distinct "NAMESPACE"), sum(sys_op_opns
ize("NAMESPACE")), substrb(dump(min("NAMESPACE"),16,0,64),1,240), substrb(dump(max("NAMESPACE"),16,0,64),1,240), count("EDITION_NAME"), count(distinct "EDITION_NAME"), sum(sys_op_opnsize("EDITION_NAME
")), substrb(dump(min(substrb("EDITION_NAME",1,64)),16,0,64),1,240), substrb(dump(max(substrb("EDITION_NAME",1,64)),16,0,64),1,240), count("SHARING"), count(distinct "SHARING"), sum(sys_op_opnsize("SH
ARING")), substrb(dump(min("SHARING"),16,0,64),1,240), substrb(dump(max("SHARING"),16,0,64),1,240), count("EDITIONABLE"), count(distinct "EDITIONABLE"), sum(sys_op_opnsize("EDITIONABLE")), substrb(dum
p(min("EDITIONABLE"),16,0,64),1,240), substrb(dump(max("EDITIONABLE"),16,0,64),1,240), count("ORACLE_MAINTAINED"), count(distinct "ORACLE_MAINTAINED"), sum(sys_op_opnsize("ORACLE_MAINTAINED")), substr
b(dump(min("ORACLE_MAINTAINED"),16,0,64),1,240), substrb(dump(max("ORACLE_MAINTAINED"),16,0,64),1,240), count("APPLICATION"), count(distinct "APPLICATION"), sum(sys_op_opnsize("APPLICATION")), substrb
(dump(min("APPLICATION"),16,0,64),1,240), substrb(dump(max("APPLICATION"),16,0,64),1,240), count("DEFAULT_COLLATION"), count(distinct "DEFAULT_COLLATION"), sum(sys_op_opnsize("DEFAULT_COLLATION")), su
bstrb(dump(min(substrb("DEFAULT_COLLATION",1,64)),16,0,64),1,240), substrb(dump(max(substrb("DEFAULT_COLLATION",1,64)),16,0,64),1,240), count("DUPLICATED"), count(distinct "DUPLICATED"), sum(sys_op_op
nsize("DUPLICATED")), substrb(dump(min("DUPLICATED"),16,0,64),1,240), substrb(dump(max("DUPLICATED"),16,0,64),1,240), count("SHARDED"), count(distinct "SHARDED"), sum(sys_op_opnsize("SHARDED")), subst
rb(dump(min("SHARDED"),16,0,64),1,240), substrb(dump(max("SHARDED"),16,0,64),1,240), count("CREATED_APPID"), count(distinct "CREATED_APPID"), sum(sys_op_opnsize("CREATED_APPID")), substrb(dump(min("CR
EATED_APPID"),16,0,64),1,240), substrb(dump(max("CREATED_APPID"),16,0,64),1,240), count("CREATED_VSNID"), count(distinct "CREATED_VSNID"), sum(sys_op_opnsize("CREATED_VSNID")), substrb(dump(min("CREAT
ED_VSNID"),16,0,64),1,240), substrb(dump(max("CREATED_VSNID"),16,0,64),1,240), count("MODIFIED_APPID"), count(distinct "MODIFIED_APPID"), sum(sys_op_opnsize("MODIFIED_APPID")), substrb(dump(min("MODIF
IED_APPID"),16,0,64),1,240), substrb(dump(max("MODIFIED_APPID"),16,0,64),1,240), count("MODIFIED_VSNID"), count(distinct "MODIFIED_VSNID"), sum(sys_op_opnsize("MODIFIED_VSNID")), substrb(dump(min("MOD
IFIED_VSNID"),16,0,64),1,240), substrb(dump(max("MODIFIED_VSNID"),16,0,64),1,240) from "SCOTT"."TEST2" t  where TBL$OR$IDX$PART$NUM("SCOTT"."TEST2",0,4,0,"ROWID") = :objn

;
