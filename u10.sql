--
--
--
-------------------------------------------------------------
@save_sqlplus_settings

col username for a15
col program for a30
col spid for 999999 head 'Spid'
col kill for a12 head 'Sid,Serial#'
col usterm for a40 head 'Username:Terminal:OSUser'
col logon for a11
col status for a1 head 'S'
col min for a11 head 'MinLastCall'
col wait_class for a10
col minw for 999999 head 'MinW'
col state for a17
set lines 160 pages 66 feed on trims on trim on
select 
       to_char(a.sid)||','||to_char(a.serial#) as kill,
       b.spid as spid,
       to_char(a.logon_time,'dd/mm HH24:MI') as Logon,  
       to_char((last_call_et/60),'9999999.99') min,
       substr(a.status,1,1) as status,
       a.username||':'||a.terminal||':'||a.osuser as usterm,
       substr(trim(replace(a.program,'TNS V1-V3','TNS')),(-1)*least(30,length(trim(replace(a.program,'TNS V1-V3','TNS'))))) as program,
       wait_class,
       seconds_in_wait/60 minw,
       state
  from 
       v$session a, v$process b
  where 
       a.paddr = b.addr
  order by
       a.username,a.logon_time;

@restore_sqlplus_settings

