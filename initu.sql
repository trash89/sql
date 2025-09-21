--
--  Script    : initu.sql
--  Purpose   : Show the undocumented parameters
--  Tested on : 12c,19c,23c
--
@save_sqp_set

set lines 168 pages 50

col PARAMETER       for a50
col DESCRIPTION     for a90 word_wrapped
col SESSION_VALUE   for a12 head 'Sess'
col INSTANCE_VALUE  for a12 head 'Inst'

spool /tmp/initundocumented.lst
SELECT 
     a.ksppinm AS parameter
    ,a.ksppdesc AS description
    ,b.ksppstvl AS session_value
    ,c.ksppstvl AS instance_value
FROM  
     sys.x$ksppi a
    ,sys.x$ksppcv b
    ,sys.x$ksppsv c
WHERE  
    a.indx = b.indx
    AND a.indx = c.indx
    AND a.ksppinm LIKE '/_%' ESCAPE '/'
ORDER BY 
    a.ksppinm
;
spool off

@rest_sqp_set

ed /tmp/initundocumented.lst
