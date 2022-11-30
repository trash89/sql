set termout off pages 200 lines 180 trim on trims off
column count format 99999999999
column value format 99999999999
column MisRat format 99.9999
column ImmedMissRat format 99.9999
column time_waited format 99999999999999999
variable dbbg number;
variable cg number;
variable pr number;
variable rlsr number;
variable re number;
begin
  -- Buffer Cache Hit Ratio: Target BCHR>95
  select value into :dbbg 
  from 
       v$sysstat 
  where 
       name='db block gets';
  select value into :cg 
  from 
       v$sysstat 
  where 
       name='consistent gets';
  select value into :pr 
  from  
       v$sysstat 
  where 
       name='physical reads';
  -- Log Buffer Hit Ratio : Target 1/5000
  select value into :rlsr 
  from 
       v$sysstat 
  where 
       name='redo log space requests';
  select value into :re 
  from 
       v$sysstat 
  where 
       name='redo entries';
end;
/
set termout on

--@system_times

set head off feed off
select 'BufHitRatio(>95%) = '||to_char((1-(:pr/(:dbbg+:cg)))*100,'999.99') valoare  from dual;

select 'LibCache HitRatio = '||to_char((1-(sum(reloads)/sum(pins)))*100,'999.99')
from v$librarycache;

select 'DataDict Miss%    = '||to_char((sum(getmisses)/sum(gets)),'999.99')
from v$rowcache;
set head on

prompt Latch Contention Cache Buffers and Library Cache
select 
substr(name,1,25),gets,misses,immediate_gets,immediate_misses,
       to_char(misses/decode(gets,0,1,gets)*100,'999.99') as "MisRat",
       to_char(immediate_misses/decode(immediate_gets,0,1,immediate_gets)*100,'999.99') as "ImmMissRat"
from v$latch 
where (misses>0 or immediate_misses>0) and (name like 'cache bu%' or name like 'library cach%');
clear columns
set lines 110 pages 22 head on feed on
