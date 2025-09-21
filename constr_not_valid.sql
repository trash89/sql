--
--  Script    : constr_not_valid.sql
--  Purpose   : show constraints FROM dba_constraints where (status != 'ENABLED' or validated !='VALIDATED')
--  Tested on : 10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 200 pages 50

undef own
accept own char prompt 'Owner?(%)      : ' default ''

col constraint_name     for a30              head 'Constraint Name'
col constraint_type     for a1               head 'C Type'
col table_name          for a30              head 'Table'
col search_condition    for a55              head 'Search Cond.'
col status              for a8               head 'Status'
col deferrable          for a14              head 'Deferrable'
col deferred            for a9               head 'Deferred'
col validated           for a13              head 'Validated'
col generated           for a14              head 'Generated'
col bad                 for a3               head 'Bad'
col rely                for a4               head 'Rely'
col invalid             for a7               head 'Invalid'
ttitle left 'dba_constraints'
SELECT
   constraint_name
  ,constraint_type
  ,table_name
  ,search_condition
  ,status
  ,deferrable
  ,deferred
  ,validated
  ,generated
  ,bad
  ,rely
  ,invalid
FROM
   dba_constraints
WHERE
   owner LIKE upper('%&&own%')
   and (status != 'ENABLED' or validated !='VALIDATED')
ORDER BY
   owner
  ,table_name
  ,constraint_name
;

undef own

@rest_sqp_set
