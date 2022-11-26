--
--  Script : r.sql
--  Author : Marius RAICU
--  Purpose: Show the rollback segments activity and settings
--  For    : 9i
--  Obs    : This script is parallel server(OPS and RAC) aware.
--  To do  : test and validate on 817 OPS and earlier versions of Oracle
------------------------------------------------------------------------
@save_sqlplus_settings

set lines 130 pages 200 trims off trim on feed off
col extents       for 9999 head 'Exts'
col swe           for a15 head 'ShWrEx'
col RSize         for 99999.99 head 'RSize(M)'
col HWMSize       for 99999.99 head 'HWM(M)'
col Ini_Next      for a13 head 'IniNextEXT(M)'
col segment_name  for a15
col username      for a10
col Tx            for 99
col machine       for a25
col osuser        for a20
col Kill          for a10
col status        for a10
col min_max       for a10 head 'MinMax Ex'
col OptSize       for 99999 head 'Opt(M)'
col extends       for 9999 head 'Extends'
col instance_num  for a1 head 'I'
select 
    d.segment_name,
    d.owner,
    nvl(d.instance_num,'1') as instance_num, 
    d.status,
    s.extents,
    round(s.rssize/1024/1024) as RSize,
    s.xacts as Tx,
    s.hwmsize/1024/1024 HWMSize,
    to_char(s.shrinks)||'/'||to_char(s.wraps)||'/'||to_char(s.extends) as swe,
    ltrim(to_char(round(d.initial_extent/1024/1024),'9999.99'))||'/'||ltrim(to_char(round(d.next_extent/1024/1024),'9999.99')) as ini_next,
    lpad(to_char(d.min_extents)||'/'||to_char(d.max_extents),10) as min_max,
    round(s.optsize/1024/1024) as OptSize
from 
    dba_rollback_segs d,gv$rollstat s
where d.segment_id=s.usn;

col instance_num  for 99    head 'I'
col name    for a10   head 'RB Name'
col start_time          for a17         head 'Start Time'
col usedbr              for a15         head 'Used Blocks/Recs'
Prompt Rollback Segments in Use:
select 
       nvl(t.inst_id,1) as instance_num,
       to_char(s.sid)||','||to_char(s.serial#) as Kill, 
       s.username, 
       r.segment_name,
       t.start_time,
       s.machine,
       s.osuser,
       t.recursive,
       to_char(used_ublk)||'/'||to_char(used_urec) as usedbr
from 
     gv$transaction t,gv$session s, dba_rollback_segs r
where 
     nvl(s.inst_id,1)=nvl(t.inst_id,1) and
     t.addr=s.taddr and
     t.xidusn = r.segment_id;

set lines 160 feed on
clear columns

@restore_sqlplus_settings
