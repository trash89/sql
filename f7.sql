set lines 150 pages 200
CLEAR computes
COLUMN FILE_NAME                FORMAT A50
COLUMN TABLESPACE_NAME          FORMAT A25
COLUMN MEG                      FORMAT 99,999.90
rem BREAK ON TABLESPACE_NAME SKIP 1 ON REPORT
rem COMPUTE SUM OF MEG ON TABLESPACE_NAME
break on report
COMPUTE sum of meg on REPORT
SELECT tablespace_name, file_name, status,bytes / 1048576 meg
  FROM dba_data_files
 ORDER BY tablespace_name;
CLEAR columns
CLEAR computes
set lines 150 pages 22

