--
--  Script : r.sql
--  Purpose: Show the rollback segments activity and settings
--  For    : 12c,19c
--
@save_sqp_set

set lines 176 pages 50

col sidser      for a15 head 'Sid,S#'
col sql_id      for a13
col start_time  for a17 head 'Start Time'
col ttype       for a15 head 'Spc/Rec/Und/Ptx'
col usedbr      for a15 head 'Recs/Blo/Undo'
col io          for a16 head 'LogIO/PhyIO'
col consist     for a18 head 'ConsistGet/Chg'
col os          for a60 head 'OrclUser -> OSUser@machine'
ttitle left 'v$transaction, v$session'
SELECT
    to_char(s.sid)||','||to_char(s.serial#)                                                                             as sidser
   ,s.sql_id
   ,t.start_time
   ,lpad(t.space,3)||'/'||lpad(t.recursive,3)||'/'||lpad(t.noundo,3)||'/'||lpad(t.ptx,3)                                as ttype   
   ,lpad(to_char(t.used_urec)||'/'||to_char(t.used_ublk)||'/'||to_char(t.used_ublk * to_number(x.value)/1024)||'K',15)  as usedbr
   ,lpad(to_char(t.log_io)||'/'||to_char(t.phy_io),16)                                                                  as io
   ,lpad(to_char(t.cr_get)||'/'||to_char(t.cr_change),18)                                                               as consist
   ,trim(nvl(s.username,'SYS'))||' -> '||trim(substr(trim(s.osuser)||'@'||trim(s.machine),1,35))                        as os
FROM
    gv$transaction    t
   ,gv$session        s
   ,gv$parameter      x
WHERE
    t.inst_id=s.inst_id
    AND t.inst_id=to_number(sys_context('USERENV','INSTANCE'))  
    AND t.inst_id=x.inst_id
    AND t.addr=s.taddr
    AND x.name  = 'db_block_size'
    AND sys_context('USERENV','CON_ID')=t.con_id
    AND t.con_id=s.con_id
ORDER BY 
    s.sid
;

@rest_sqp_set
