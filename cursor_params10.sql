--
--  Script    : cursor_params10.sql
--  Purpose   : This script enables you to check whether the current settings for 
--              the SESSION_CACHED_CURSORS or the OPEN_CURSORS parameters are a
--              constraint for the current user. If either of the Usage column 
--              figures approaches 100%, then you should increase that parameter.
--              This information is not restricted to cursors associated with  analytic workspaces.
--  Tested on : 10g+
--
@save_sqp_set

set lines 50 pages 50
SELECT
       'session_cached_cursors'                                   parameter
      ,lpad(value,5)                                              value
      ,decode(value,0,'  n/a',to_char(100*used/value,'990')||'%') usage
FROM
      (SELECT max(s.value)used 
        FROM gv$statname n,gv$sesstat s
        WHERE 
            s.inst_id=s.inst_id
            AND s.inst_id=to_number(sys_context('USERENV','INSTANCE'))
            AND n.name='session cursor cache count' 
            AND s.statistic#=n.statistic#
      ),
      (SELECT p.value 
        FROM gv$parameter p
        WHERE 
            p.name='session_cached_cursors'
            AND p.inst_id=to_number(sys_context('USERENV','INSTANCE'))
      )
UNION
ALL
SELECT
       'open_cursors'
      ,lpad(value,5)
      ,to_char(100*used/value,'990')||'%'
FROM
      (SELECT max(sum(s.value)) used 
        FROM gv$statname n ,gv$sesstat s
        WHERE 
           n.inst_id=s.inst_id
           AND n.inst_id=to_number(sys_context('USERENV','INSTANCE'))
           AND n.name IN ('opened cursors current','session cursor cache count') 
           AND s.statistic#=n.statistic# 
       GROUP BY s.sid
      ),
      (SELECT p.value 
        FROM gv$parameter p
        WHERE 
           p.name='open_cursors'
           AND p.inst_id=to_number(sys_context('USERENV','INSTANCE'))
      )
;

@rest_sqp_set
