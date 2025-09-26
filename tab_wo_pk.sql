--
--  Script    : tab_wo_pk.sql
--  Purpose   : show tables FROM dba_tables
--  Tested on : 10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 70 pages 50

undef own
accept own char prompt 'Owner?(%)      : ' default ''

col tab for a60 head 'Tables without PK/UK'
select  
    owner||'.'||table_name as tab
from    
    dba_tables dt
where 
    not exists (select 'true' from dba_constraints dc where dc.table_name = dt.table_name and dc.constraint_type in ('P','U'))
    and owner not in (select username from dba_users where oracle_maintained='Y')
    and not exists(select 'true' from dba_indexes i where i.table_owner=dt.owner and i.table_name=dt.table_name and i.uniqueness='UNIQUE')
    and owner like upper('%&&own%')
order by 
     owner
    ,table_name
;

undef own

@rest_sqp_set
