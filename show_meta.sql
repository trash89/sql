prompt ---------------- To obtain the DDL for a table or index, execute the following: ---------------------------------------;
prompt SET LONG 20000000;
prompt SET PAGESIZE 0;

prompt execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'PRETTY',true);;
prompt execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SQLTERMINATOR',true);;
prompt execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'STORAGE',false,'TABLE');;
prompt execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'TABLESPACE',false,'TABLE');;
prompt execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'CONSTRAINTS',true,'TABLE');;
prompt execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'REF_CONSTRAINTS',false,'TABLE');;
prompt execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'CONSTRAINTS_AS_ALTER',true,'TABLE');;
prompt execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SIZE_BYTE_KEYWORD',true,'TABLE');;
prompt execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES',false,'TABLE');;
prompt execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES',false,'INDEX');;
prompt execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES',false,'CONSTRAINTS');;
prompt execute dbms_metadata.set_transform_param(dbms_metadata.session_transform,'INHERIT',true);;

prompt select dbms_metadata.get_ddl('INDEX','IDX_TEST') from dual;;
prompt select dbms_metadata.get_ddl('TABLE','TEST') from dual;;
prompt ----------------------------------------------------------------------------------------------------------------------;