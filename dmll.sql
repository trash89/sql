COLUMN owner            FORMAT a15      HEADING 'User'
COLUMN session_id                       HEADING 'SID'
COLUMN mode_held        FORMAT a20      HEADING 'Mode|Held'
COLUMN mode_requested   FORMAT a20      HEADING 'Mode|Requested'
SET FEEDBACK OFF ECHO OFF PAGES 59 LINES 200
SELECT NVL (owner, 'SYS') owner, session_id, name, mode_held, mode_requested
  FROM sys.dba_dml_locks
 ORDER BY 2
/
CLEAR COLUMNS
SET FEEDBACK ON ECHO ON PAGES 22 LINES 200
TTITLE OFF
