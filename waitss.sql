@save_sqlplus_settings

set term off
column inst noprint new_value inst
select 'waitss_'||instance||'_'||to_char(open_time,'dd_mm_rrrr_hh24_mi')||'.lst' as inst from v$thread;
set term on
set lines 110 pages 80 feed off newp none trims on trim off
column tot_csecs  format 999,999,999,999 heading 'Time|Waited(CSec)'
column max_csecs format 999,999,999 heading 'Max|Wait(CSec)'
column event format a47 heading 'Event Name'
column diff_timeM format 99999999.99 heading 'Diff Time(Min)'
column diff_timeS format 999999999.99 heading 'Diff Time(Sec)'
column waits format 999,999,999 heading 'Total|Waits'
column timeouts format 999,999 heading 'Total|Timeouts'
column Startup_Time format a20
column Current_time format a19
spool &&inst
prompt System summary perspective (V$SYSTEM_EVENT)
select 
       d.kslednam as event,
       s.ksleswts as waits,
       s.kslestmo as timeouts,
       s.kslestim as tot_csecs,
       s.kslesmxt as max_csecs
--       (average_wait/100) as average_wait 
from 
    sys.x$kslei s,
    sys.x$ksled d
where s.ksleswts!=0
      and s.indx=d.indx
      and d.inst_id=userenv('instance')
      and s.inst_id=userenv('instance') and
      d.kslednam not like 'SQL*Net%' and
      d.kslednam not like '%ipc%' and
      d.kslednam not like '%timer%' and
      d.kslednam not like '%message%' and
      d.kslednam not like '%pipe get%' and
      d.kslednam not like '%wakeup%' and
      d.kslednam not like '%slave%' and
      d.kslednam not like '%Null%'   
order by 4;

set trimspool on pages 1023 verify off feed off
ttitle off
btitle off
--clear columns
clear breaks

column  file#           format  9999      heading "File"
column  phyrds          format  999999999 heading "Reads"
column  phyblkrd        format  999999999 heading "Blks_Rd"
column  readtim         format  99999.999  heading "Avg_Time"
column  phywrts         format  999999999 heading "Writes"
column  phyblkwrt       format  999999999 heading "Blks_wrt"
column  writetim        format  99999.999  heading "Avg_Time"

prompt File summary perspective (V$FILESTAT+V$TEMPSTAT)
select 
        file#,
        phyrds,
        phyblkrd,
        round(readtim/decode(phyrds,0,1,phyrds),3)      readtim,
        phywrts,
        phyblkwrt,
        round(writetim/decode(phywrts,0,1,phywrts),3)   writetim
from v$filestat
order by file#
;
select 
        file#,
        phyrds,
        phyblkrd,
        round(readtim/decode(phyrds,0,1,phyrds),3)      readtim,
        phywrts,
        phyblkwrt,
        round(writetim/decode(phywrts,0,1,phywrts),3)   writetim
from v$tempstat
order by file#
;
select instance,
       to_char(logon_time,'dd/mm/rrrr hh24:mi:ss') as Startup_Time,
       to_char(sysdate,'dd/mm/rrrr hh24:mi:ss') as Current_Time,
       (sysdate-logon_time)*24*60 as Diff_TimeM, 
       (sysdate-logon_time)*24*60*60 as Diff_TimeS 
from v$session,v$thread,dual where sid=1;
spool off
clear columns
set lines 110 pages 22 feed on 

@restore_sqlplus_settings

